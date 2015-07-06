(function($){
  var rs = {
    init: function(){
      this.onHamsterAction();
    },
    
    onHamsterAction: function(){
      $( document ).on("ajax:success", "a.hamster-action", function(xhr, data, status){
        if ( $(this).hasClass('start') ){
          $('.stop').hide()
          $('.start').show()
          $(this).hide()
          stop = $(this).parent().find('.stop');
          stop.show();
          stop.attr('href', data.url);
        } else {
          $(this).hide();
          $(this).parent().find('.start').show();
        }
      });
    }

  }

  $(function(){
    rs.init();
  });
})(jQuery)
