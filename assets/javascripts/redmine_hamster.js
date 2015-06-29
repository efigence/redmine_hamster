(function($){
  var hamster = {
    init: function(){
      this.bindShowButtonSave();
      this.bindHideButtonSave();
      // this.bindShowRemoveButton();
      // this.bindHideRemoveButton();
      this.bindRemoveHamster();
      this.bindRaportHamster();
    },
// remove-hamster
    bindShowButtonSave: function(){
      $('.spend_time input').keyup(function(e) {
        $(e.currentTarget).parent().parent().children('td.spend_time').find('.action-save').fadeIn(1000);
      });
    },

    bindHideButtonSave: function(){
      var new_val = null;
      $('.action-save').on('click', function(e) {
        new_val = $(e.target).closest('tr').find('#hamster_spend_time').val();
        $(e.target).closest('tr').find('.hamster-hours').val(new_val);
        $(e.target).fadeOut(1000);
      });
    },

    bindShowRemoveButton: function(){
       $('tr.list-hamsters').mouseenter(function(e) {
          $(e.currentTarget).find('td.remove-action').fadeIn(500);
        });
    },

    bindHideRemoveButton: function(){
      $('tr.list-hamsters').mouseleave(function(e) {
        $(e.currentTarget).find('td.remove-action').fadeOut(500);
      });
    },

    bindRemoveHamster: function(){
      $('.remove-hamster').on('click', function(e) {
        $(e.currentTarget).closest('tr').fadeOut(300);
      });
    },

    bindRaportHamster: function(){
      $('.raport-hamster').on('click', function(e) {
        var activity_element =  $(e.target).closest('tr').find('#time_entry_activity_id')
        if ( activity_element && activity_element.val() === ""){
          $(activity_element).addClass('error');
          return false;
        }else{
          $(e.currentTarget).closest('tr').fadeOut(300);
        }
      });
    }
  }

  $(function(){
    hamster.init();
  });
})(jQuery)