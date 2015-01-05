$( document ).ready(function() {
    $('#checkbox1').change(function() {
        if($(this).is(":checked")) {
            var returnVal = confirm("Are you sure?");
            $(this).attr("checked", returnVal);
        }
        $('#textbox1').val($(this).is(':checked'));        
    });
});