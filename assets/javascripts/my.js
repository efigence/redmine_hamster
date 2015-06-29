(function($){
  var my = {
    init: function(){
      this.bindTimePicker();
    },

    bindTimePicker: function(){
      $('#start_at').timepicker({ timeFormat: 'HH:mm' });
      $('#end_at').timepicker({ timeFormat: 'HH:mm' });
    }
  }

  $(function(){
    my.init();
  });
})(jQuery)
