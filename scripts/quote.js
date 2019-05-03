// Description:
//   Remember messages and quote them back
//
// Dependencies:
//   underscore: ~1.7.0
//   natural: ~0.1.28
//   msgpack: ~0.2.4
//
// Configuration:
//   HUBOT_QUOTE_CACHE_SIZE=N - Cache the last N messages for each user for potential remembrance (default 25).
//   HUBOT_QUOTE_STORE_SIZE=N - Remember at most N messages for each user (default 100).
//   HUBOT_QUOTE_INIT_TIMEOUT=N - wait for N milliseconds for brain data to load from redis. (default 10000)
//
// Commands:
//   hubot grab <user> <text> - grabs most recent message from <user> containing <text>
//   hubot forget <user> <text> - forget most recent remembered message from <user> containing <text>
//   hubot quote [<user>] [<text>] - quote a random remembered message that is from <user> and/or contains <text>
//   hubot quotemash [<user>] [<text>] - quote some random remembered messages that are from <user> and/or contain <text>
//   hubot <text>|<user>mash - quote some random remembered messages that from <user> or contain <text>
//
// Author:
//   b3nj4m

var _ = require('underscore');
var natural = require('natural');
var msgpack = require('msgpack');

var stemmer = natural.PorterStemmer;

var CACHE_SIZE = process.env.HUBOT_QUOTE_CACHE_SIZE ? parseInt(process.env.HUBOT_QUOTE_CACHE_SIZE) : 25;
var STORE_SIZE = process.env.HUBOT_QUOTE_STORE_SIZE ? parseInt(process.env.HUBOT_QUOTE_STORE_SIZE) : 100;
var INIT_TIMEOUT = process.env.HUBOT_QUOTE_INIT_TIMEOUT ? parseInt(process.env.HUBOT_QUOTE_INIT_TIMEOUT) : 10000;

function uniqueStems(text) {
  return _.unique(stemmer.tokenizeAndStem(text));
}

var messageTmpl = _.template('<%= user.name %>: <%= text %>');

var userNotFoundTmpls = [
  "I don't know any <%= username %>",
  "<%= username %> is lame."
];
userNotFoundTmpls = _.map(userNotFoundTmpls, _.template);

var notFoundTmpls = [
  "I don't know anything about <%= text %>.",
  "Wat."
];
notFoundTmpls = _.map(notFoundTmpls, _.template);

function randomItem(list) {
  return list[_.random(list.length - 1)];
}

//get random subset of items (mutates original list)
function randomItems(list, limit) {
  var messages = new Array(Math.min(list.length, limit));

  for (var i = 0; i < messages.length; i++) {
    messages[i] = list.splice(_.random(list.length - 1), 1)[0];
  }

  return messages;
}

function messageToString(message) {
  return messageTmpl(message);
}

function userNotFoundMessage(username) {
  return randomItem(userNotFoundTmpls)({username: username});
}

function notFoundMessage(text) {
  return randomItem(notFoundTmpls)({text: text});
}

function emptyStoreMessage() {
  return "I don't remember any quotes...";
}

function serialize(data) {
  var string;

  try {
    string = msgpack.pack(data);
  }
  catch (err) {
    //emit error?
  }

  return string;
}

function deserialize(string) {
  var data;

  //legacy (2.x and older) data was stored as JSON
  try {
    data = JSON.parse(string);
  }
  catch (err) {
    //emit error?
  }

  //new data is stored as msgpack
  if (!data) {
    try {
      data = msgpack.unpack(new Buffer(string));
    }
    catch(err) {
      //emit error?
    }
  }

  return data;
}

function robotStore(robot, key, data) {
  return robot.brain.set(key, serialize(data));
}

function robotRetrieve(robot, key) {
  return deserialize(robot.brain.get(key));
}

function stemMatches(searchText, searchStems, msg) {
  //cache stems on message
  msg.stems = msg.stems || uniqueStems(msg.text);
  //require all stems to be present
  return searchStems.length > 0 && _.intersection(searchStems, msg.stems).length === searchStems.length;
}

function textMatches(searchText, msg) {
  return msg.text.toLowerCase().indexOf(searchText.toLowerCase()) > -1;
}

function matches(searchStems, searchText, msg) {
  return searchText === '' || stemMatches(searchText, searchStems, msg) || textMatches(searchText, msg);
}

function findAllStemMatches(messageTable, text, users) {
  var stems = uniqueStems(text);
  var userIds = users ? _.pluck(users, 'id') : _.keys(messageTable);

  return _.flatten(_.map(userIds, function(userId) {
    if (messageTable[userId] === undefined) {
      return [];
    }
    else {
      return _.filter(messageTable[userId], matches.bind(this, stems, text));
    }
  }));
}

function findFirstStemMatch(messageTable, text, users) {
  var userIds = users ? _.pluck(users, 'id') : _.keys(messageTable);
  var message = null;
  var messageIdx = null;
  var userId = null;

  var stems = uniqueStems(text);

  _.find(userIds, function(usrId) {
    userId = usrId;

    if (messageTable[userId] === undefined) {
      return false;
    }
    else {
      message = _.find(messageTable[userId], function(msg, idx) {
        messageIdx = idx;
        return matches(stems, text, msg);
      });

      return !!message;
    }
  });

  if (message) {
    return {
      message: message,
      messageIdx: messageIdx,
      userId: userId
    };
  }

  return null;
}

function start(robot) {
  var store = robotStore.bind(this, robot);
  var retrieve = robotRetrieve.bind(this, robot);

  robot.brain.setAutoSave(true);

  var messageCache = retrieve('quoteMessageCache');
  if (!messageCache) {
    store('quoteMessageCache', {});
  }

  var messageStore = retrieve('quoteMessageStore');
  if (!messageStore) {
    store('quoteMessageStore', {});
  }

  var hubotMessageRegex = new RegExp('^[@]?(' + robot.name + ')' + (robot.alias ? '|(' + robot.alias + ')' : '') + '[:,]?\\s', 'i');

  robot.respond(/grab ([^\s]*) (.*)/i, function(msg) {
    var username = msg.match[1];
    var text = msg.match[2];

    var messageCache = retrieve('quoteMessageCache');
    var messageStore = retrieve('quoteMessageStore');

    //TODO search for users in messageStore in case they've been removed? (name change implications?)
    var users = robot.brain.usersForFuzzyName(username);

    var match = findFirstStemMatch(messageCache, text, users);

    if (match) {
      messageStore[match.userId] = messageStore[match.userId] || [];
      messageStore[match.userId].unshift(match.message);

      messageCache[match.userId].splice(match.messageIdx, 1);

      store('quoteMessageStore', messageStore);
      store('quoteMessageCache', messageCache);

      //TODO configurable responses
      msg.send("remembering " + messageToString(match.message));
    }
    else if (users.length === 0) {
      msg.send(userNotFoundMessage(username));
    }
    else {
      msg.send(notFoundMessage(text));
    }
  });

  robot.respond(/forget ([^\s]*) (.*)/i, function(msg) {
    var username = msg.match[1];
    var text = msg.match[2];

    var messageStore = retrieve('quoteMessageStore');

    var users = robot.brain.usersForFuzzyName(username);

    var match = findFirstStemMatch(messageStore, text, users);

    if (match) {
      messageStore[match.userId].splice(match.messageIdx, 1);
      store('quoteMessageStore', messageStore);
      msg.send("forgot " + messageToString(match.message));
    }
    else if (users.length === 0) {
      msg.send(userNotFoundMessage(username));
    }
    else {
      msg.send(notFoundMessage(text));
    }
  });

  robot.respond(/quote($| )([^\s]*)?( (.*))?/i, function(msg) {
    var username = msg.match[2];
    var text = msg.match[4] || '';
    var users;

    var messageStore = retrieve('quoteMessageStore');

    if (username) {
      users = robot.brain.usersForFuzzyName(username);

      if (users.length === 0) {
        //username is optional, so include it in `text` if we don't find any users
        text = username + (text ? ' ' + text : '');
        users = null;
      }
    }

    var matches = findAllStemMatches(messageStore, text, users);

    if (matches && matches.length > 0) {
      message = randomItem(matches);
      msg.send(messageToString(message));
    }
    else if (users && users.length === 0) {
      msg.send(userNotFoundMessage(username));
    }
    else if (!text) {
      msg.send(emptyStoreMessage());
    }
    else {
      msg.send(notFoundMessage(text));
    }
  });

  robot.respond(/(quotemash( ([^\s]*))?( (.*))?)|((([^\s]*))mash)/i, function(msg) {
    var username = msg.match[3] || msg.match[8] || '';
    var text = msg.match[5] || '';
    var limit = 10;
    var users = null;

    var messageStore = retrieve('quoteMessageStore');

    if (username) {
      users = robot.brain.usersForFuzzyName(username);

      if (users.length === 0) {
        //username is optional, so include it in `text` if we don't find any users
        text = username + (text ? ' ' + text : '');
        users = null;
      }
    }

    var matches = findAllStemMatches(messageStore, text, users);

    if (matches && matches.length > 0) {
      msg.send.apply(msg, _.map(randomItems(matches, limit), messageToString));
    }
    else if (!text) {
      msg.send(emptyStoreMessage());
    }
    else {
      msg.send(notFoundMessage(text));
    }
  });

  robot.hear(/.*/, function(msg) {
    //TODO existing way to test this somewhere??
    if (!hubotMessageRegex.test(msg.message.text)) {
      var userId = msg.message.user.id;
      var messageCache = retrieve('quoteMessageCache');

      messageCache[userId] = messageCache[userId] || [];

      if (messageCache[userId].length === CACHE_SIZE) {
        messageCache[userId].pop();
      }

      messageCache[userId].unshift({
        text: msg.message.text,
        user: msg.message.user
      });

      store('quoteMessageCache', messageCache);
    }
  });
}

module.exports = function(robot) {
  var loaded = _.once(function() {
    console.log('starting hubot-quote...');
    start(robot);
  });

  if (_.isEmpty(robot.brain.data) || _.isEmpty(robot.brain.data._private)) {
    robot.brain.once('loaded', loaded);
    setTimeout(loaded, INIT_TIMEOUT);
  }
  else {
    loaded();
  }
};
