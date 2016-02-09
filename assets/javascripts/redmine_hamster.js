(function ($) {
    var hamster = {
        init: function () {
            this.bindShowButtonSave();
            this.bindHideButtonSave();
            this.bindRemoveHamster();
            this.bindRaportHamster();
            this.bindSortIssues();
            this.calculateSpentTime();
            this.bindExpandHamster();
            this.bindRemoveHamsterDetail();
            this.bindTimePicker();
            this.bindShowTimeRange();
            this.bindChangeTimeRange();
            this.bindSaveJournal();
        },

        bindSaveJournal: function () {
            $('.save-journal').on('click', function (e) {
                e.stopPropagation();
                var jid = $(this).data('journal');
                $('form#edit_hamster_journal_' + jid).submit();
                $(this).hide();
                false
            });
        },

        bindTimePicker: function () {
            $('em.time-from').timepicker({
                minTime: '06:00',
                maxTime: '22:00',
                timeFormat: 'H:i',
                step: 5,
                scrollDefault: 'now'
            });
            $('em.time-to').timepicker({
                minTime: '06:00',
                maxTime: '22:00',
                timeFormat: 'H:i',
                step: 5,
                scrollDefault: 'now'
            });
        },

        bindShowTimeRange: function () {
            $('em.time-from').on('click', function () {
                $(this).timepicker('show');
            });
            $('em.time-to').on('click', function () {
                $(this).timepicker('show');
            });
        },

        bindChangeTimeRange: function () {
            $('em.time-from').on('changeTime', function () {
                var $this = $(this),
                    val = $this.data('uiTimepickerValue');
                $this.text(val);
                $this.parents('.list').find('input.time-from').val(val);
                hamster.calculateTime($this);
            });
            $('em.time-to').on('changeTime', function () {
                var $this = $(this),
                    val = $this.data('uiTimepickerValue');
                $this.text(val);
                $this.parents('.list').find('input.time-to').val(val)
                hamster.calculateTime($this);
            });
        },

        calculateTime: function (element) {
            var $parent = element.parent();
            var from = $parent.find('em.time-from').text(),
                to = $parent.find('em.time-to').text(),
                diff = moment.utc(moment(to, "H:mm").diff(moment(from, "H:mm"))).format("H:mm");
            var rounded_float = Number(moment.duration(diff).asHours()).toFixed(2)
            hamster.updateHamsterInputOnRemove($parent); //substact old value
            $parent.parents('tr.list').children('.jsummary').text(rounded_float);
            hamster.updateHamsterInputOnTimeRangeChange($parent, rounded_float);
            $parent.find('.save-journal').show();
        },

        updateHamsterInputOnTimeRangeChange: function (parent, value) {
            var parent = $(parent).closest('tr');
            var $hamster_input = $('.input-' + $(parent).data('hamster'));
            var new_val = parseFloat($hamster_input.val()) + parseFloat(value);
            $hamster_input.val(new_val.toFixed(2));
            $hamster_input.closest('tr').find('.hamster-hours').val(new_val.toFixed(2));
            hamster.calculateSpentTime();
            parent.parents('.list').find('input.summary').val(value);
            parent.parents('.list').find('input.hamster_sum').val(new_val);
        },

        bindExpandHamster: function () {
            $('.hamster-journal').on('click', function (e) {
                e.stopPropagation;
                if ($(e.target).hasClass("collapsed")) {
                    $(e.target).removeClass('collapsed');
                    $('tbody#details-hamster-' + e.target.id).fadeIn(400);
                } else {
                    $(e.target).addClass("collapsed");
                    $('tbody#details-hamster-' + e.target.id).fadeOut(400);
                }
            });
        },

        bindRemoveHamsterDetail: function () {
            $('.remove-journal-item').on('ajax:success', function (e) {
                $(e.currentTarget).closest('tr').removeClass('list');
                $(e.currentTarget).closest('tr').fadeOut(300, function () {
                    $(this).remove()
                });
                setTimeout(function () {
                    hamster.updateHamsterInputOnRemove(e.target);
                }, 200);
            });
        },

        updateHamsterInputOnRemove: function (target) {
            _target = target;
            parent = _target.closest('tr');
            substract = $(parent).find('td.jsummary').text();
            var $hamster_input = $('.input-' + $(parent).data('hamster'));
            old_val = $hamster_input.val();
            new_val = parseFloat(old_val) - parseFloat(substract);
            if (new_val < 0) {
                new_val = parseFloat("0.0");
                elements = $(_target.closest('tbody')).children('.list');
                for (i = 0; i < elements.length; i++) {
                    v = $(elements[i]).find('.jsummary').text();
                    new_val = new_val + parseFloat(v);
                }
            }
            $hamster_input.attr('value', new_val.toFixed(2))
            $hamster_input.closest('tr').find('.hamster-hours').val(new_val.toFixed(2));
            hamster.calculateSpentTime();
        },

        calculateSpentTime: function () {
            heads = $('th.date');
            for (i = 0; i < heads.length; i++) {
                date = $(heads[i]).parent().attr('id')
                var sum = 0.0;
                elems = $('tr.' + date);
                for (j = 0; j < elems.length; j++) {
                    val = $(elems[j]).find('#hamster_spend_time').val();
                    sum = sum + parseFloat(val);
                }
                $(".total-spent-time" + date).html(sum.toFixed(2));
            }
        },

        bindSortIssues: function () {
            if ($('.sort').length > 1) {
                $('.sort').last().hide();
            }
        },

        bindShowButtonSave: function () {
            $('.spend_time input').keyup(function (e) {
                $(this).closest('tr').find('.action-save').fadeIn(400);
                $(this).closest('tr').find('.hamster-hours').val($(this).val());
                hamster.calculateSpentTime();
            });
        },

        bindHideButtonSave: function () {
            var new_val = null;
            $('.action-save').on('click', function (e) {
                new_val = $(e.target).closest('tr').find('#hamster_spend_time').val();
                $(e.target).closest('tr').find('.hamster-hours').val(new_val);
                $(e.target).fadeOut(400);
            });
        },

        bindRemoveHamster: function () {
            $('.remove-hamster').on('ajax:success', function (e) {
                $(e.currentTarget).closest('tr').fadeOut(300, function () {
                    $(this).remove()
                });
                target_id = e.target.href.split("/").slice(-1)[0]
                $('tbody#details-hamster-' + target_id).remove();
                setTimeout(function () {
                    hamster.calculateSpentTime();
                }, 500);
            });
        },

        bindRaportHamster: function () {
            $('.raport-hamster').on('click', function (e) {
                var activity_element = $(e.target).closest('tr').find('#time_entry_activity_id')
                if (activity_element && activity_element.val() === "") {
                    $(activity_element).addClass('error');
                    return false;
                } else {
                    $(e.currentTarget).closest('tr').fadeOut(300, function () {
                        $(this).remove()
                    });
                    setTimeout(function () {
                        hamster.calculateSpentTime();
                    }, 500);
                    to_add = parseFloat($(this).closest('tr').find('#hamster_spend_time').val());
                    current_val = parseFloat($(this).closest('tr').parent().find('.already-raported').html());
                    new_val = to_add + current_val;
                    $(this).closest('tr').parent().find('.already-raported').html((new_val).toFixed(2));
                }
            });
        }
    }

    $(function () {
        hamster.init();
    });
})(jQuery)