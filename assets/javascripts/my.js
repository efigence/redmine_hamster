(function($){
  var my = {
    init: function(){
      this.bindTimePicker();
    },

    bindTimePicker: function(){
      $('#start_at').timepicker({ timeFormat: 'H:i' });
      $('#end_at').timepicker({ timeFormat: 'H:i' });
    }
  }

  $(function(){
    my.init();
  });
})(jQuery)
