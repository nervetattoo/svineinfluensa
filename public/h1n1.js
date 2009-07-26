/* Load when ready */
$(function() {
    console.log($('table'));
    $("table").tablesorter({sortList:[[0,0]], widgets: ['zebra']});
})
