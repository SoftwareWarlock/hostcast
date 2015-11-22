var React = require('react');
var ReactDOM = require('react-dom');
var PodcastServiceFactory = require('./PodcastsService');
var PodcastService = new PodcastServiceFactory('4586377ed7618166feb1cfaad20291049e3c4eba');

var PodcastList = React.createClass({
    getInitialState: function() {
        return {podcasts: []};
    },
    render: function() {
        var podcasts = this.state.podcasts.map(function(podcast) {
            return (
                <Podcast podcast={podcast} key={podcast.id} />
            );
        });
        return (
            <div className="podcastList">
                {podcasts}
            </div>
        );
    },
    componentDidMount: function() {
        this.loadPodcastsFromServer();
    },
    loadPodcastsFromServer: function() {
        var self = this
        PodcastService.list(function(data) {
            self.setState({podcasts: data});
        });
    },

});

var Podcast = React.createClass({
    render: function() {
        return (
            <div className="podcast">
                <h3>{this.props.podcast.title}</h3>
                <p>{this.props.podcast.description}</p>
            </div>
        );
    }
});

ReactDOM.render(
    <PodcastList url="/api/podcasts/" />,
    document.getElementById('content')
);

