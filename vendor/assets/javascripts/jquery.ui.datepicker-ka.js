jQuery(function($){
    $.datepicker.regional['ka'] = {
      closeText: 'ახლოს',
      prevText: '&#x3c;წინა',
      nextText: 'შემდეგი&#x3e;',
      currentText: 'დღეს',
      monthNames: ['იანვარი', 'თებერვალი', 'მარტი', 'აპრილი', 'მაისი', 'ივნისი', 'ივლისი', 'აგვისტო', 'სექტემბერი', 'ოქტომბერი', 'ნოემბერი', ' დეკემბერი'],
      monthNamesShort: ['იანვ', 'თებ', 'მარ', 'აპრ', 'მაისი', 'ივნ', 'ივლ', 'აგვ', 'სექტ', 'ოქტ', 'ნოემ', ' დეკ'],
      dayNames: ['კვირა', 'ორშაბათი', 'სამშაბათი', 'ოთხშაბათი', 'ხუთშაბათი', 'პარასკევი', 'შაბათი'],
      dayNamesShort: ['კვ', 'ორშ', 'სამშ', 'ოთხშ', 'ხუთშ', 'პარ', 'შაბ'],
      dayNamesMin: ['კვ', 'ორშ', 'სამშ', 'ოთხშ', 'ხუთშ', 'პარ', 'შაბ'],
      dateFormat: 'dd-mm-yy', firstDay: 0,
      isRTL: false};
    $.datepicker.setDefaults($.datepicker.regional['ka']);
});
