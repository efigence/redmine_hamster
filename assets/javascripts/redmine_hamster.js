(function($){
  var hamster = {
    init: function(){
      this.bindShowButtonSave();
      this.bindHideButtonSave();
      this.bindShowRemoveButton();
      this.bindShowHideButton();
    },

    bindShowButtonSave: function(){
      $('.spend_time input').keyup(function(e) {
        $(e.currentTarget).parent().parent().children('td.raport-action').find('.action-save').fadeIn(1000);
      });
    },

    bindHideButtonSave: function(){
      $('.action-save').on('click', function(e) {
        $(e.target).fadeOut(1000);
      });
    },

    bindShowRemoveButton: function(){
       $('tr.list-hamsters').mouseenter(function(e) {
          $(e.currentTarget).find('td.remove-action').fadeIn(500);
        });
    },
    bindShowHideButton: function(){
      $('tr.list-hamsters').mouseleave(function(e) {
        $(e.currentTarget).find('td.remove-action').fadeOut(500);
      });
    }
  }

  $(function(){
    hamster.init();
  });
})(jQuery)
