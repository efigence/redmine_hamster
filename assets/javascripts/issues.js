(function($){
  var issues = {
    init: function(){
      this.on_hamster_action();
    },
    on_hamster_action: function(){
      $('.hamster-action').on('click', function(){
        location.reload();
      });
    }

  }

  $(function(){
    issues.init();
  });
})(jQuery)
