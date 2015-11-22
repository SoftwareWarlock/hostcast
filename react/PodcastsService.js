var $ = require('jquery');

var PodcastServiceFactory = function(authToken) {
    this.list = function(success, failure) {
        $.ajax({
            url: '/api/podcasts/',
            beforeSend: function(xhr) {xhr.setRequestHeader('Authorization', 'Token ' + authToken);},
            dataType: 'json',
            cache: false,
            success: function(data) {
                success(data);
            }.bind(this),
            error: function(xhr, status, err) {
                failure(xhr, status, err)
                console.error("Failed to get podcasts", status, err.toString());
            }.bind(this)
        });
    };
};

module.exports = PodcastServiceFactory;
