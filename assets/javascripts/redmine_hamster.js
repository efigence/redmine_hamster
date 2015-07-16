(function($){
  var hamster = {
    init: function(){
      this.bindShowButtonSave();
      this.bindHideButtonSave();
      this.bindRemoveHamster();
      this.bindRaportHamster();
      this.bindSortIssues();
      this.calculateSpentTime();
    },

    calculateSpentTime: function(){
      heads = $('th.date');
      for(i = 0; i < heads.length;  i++){
        date = $(heads[i]).parent().attr('id')
        var sum = 0.0;
        elems = $('tr.' + date);
        for(j = 0; j < elems.length; j++){
          val = $(elems[j]).find('#hamster_spend_time').val();
          sum = sum + parseFloat(val);
        }
        $(".total-spent-time"+date).html(sum.toFixed(2));
      }
    },

    bindSortIssues: function(){
      if( $('.sort').length > 1 ){
        $('.sort').last().hide();
      }
      var url = window.location.href;
      $('#sort-issues').on('click', function(){
        order = $(this).data('order');
        $.ajax({
          url: url,
          type: "GET",
          data: { 'order' : order },
          success: function(data){
            document.open();
            document.write(data);
            document.close();
          }
        })
      });
    },

    bindShowButtonSave: function(){
      $('.spend_time input').keyup(function(e) {
        $(this).closest('tr').find('.action-save').fadeIn(400);
        $(this).closest('tr').find('.hamster-hours').val( $(this).val() );
        hamster.calculateSpentTime();
      });
    },

    bindHideButtonSave: function(){
      var new_val = null;
      $('.action-save').on('click', function(e) {
        new_val = $(e.target).closest('tr').find('#hamster_spend_time').val();
        $(e.target).closest('tr').find('.hamster-hours').val(new_val);
        $(e.target).fadeOut(400);
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
        $(e.currentTarget).closest('tr').fadeOut(300, function() { $(this).remove() });
        setTimeout(function() {  hamster.calculateSpentTime(); }, 500);
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
