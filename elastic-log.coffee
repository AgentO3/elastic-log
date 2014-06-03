# Description:
#   Returns logs from ElasticSearch
#
# Dependencies:
#   "elasticsearch": "~1.5.8"
#   "moment": "~2.5.1"
#   "underscore": "~1.5.2"
#
# Configuration:
#   None
#
# Commands:
#   hubot log me <query>- Queries kibana elasticsearch and returns the most recent 25 matching results
#
# Author:
#   AgentO3

url = process.env.ELASTICSEARCH_URL

elasticsearch = require('elasticsearch')
moment = require('moment')
_ = require('underscore')

client = new elasticsearch.Client({
  host: url
});

module.exports = (robot) ->
	robot.respond /log me?(.+)$/i, (msg) ->
		index = moment().format("YYYY.MM.DD")
		query = msg.match[1] || "*"
		qty = 25

		client.search(
		  index: "logstash-" + index
		  q: query
		  size: qty
		  body:
		    sort: ["@timestamp":
		      order: "desc"
		    ]
		).then ((resp) ->
		  res = ""
		  _.chain(resp.hits.hits).pluck("_source").each((value) ->
		    _.each value, (v, k) ->
		      res += k + ":" + " " + v + " "
		    res += "\n"
		  ).value()
		  msg.send res
		), (err) ->
		  console.trace err.message
