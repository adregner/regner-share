var new_access_token_showing;
var user_share_list;

document.observe('dom:loaded', function() {
  $$('a.item').each(function(item) {
    item.observe('click', add_item);
  });
  $$('img.item').each(function(item) {
    item.observe('contextmenu', add_item);
  });

  user_share_list = Element.remove('user_share_list_all'); // .remove() is on <select ...> tags

  new_access_token_showing = $('new_access_token').innerHTML;
  $('new_access_token').update("Right-click on an item to share it...");
})

function add_item(ev) {
  var item_id = this.getAttribute('data-id');
  var item_parent = $('item-'+item_id);
  var item_name = item_parent.getAttribute('data-name');
  
  if( new_access_token_showing ) {
    $('new_access_token').update(new_access_token_showing);
    $('user_share_button').observe('click', select_user_share);
    $$('form')[0].observe('submit', form_submitter);
    new_access_token_showing = null;
  }

  item_parent.remove().addClassName('selected');
  $('items').insert({'top': item_parent});
  
  //$('items_to_share').insert((new Element('div', {"class": "item"})).update(item_name));
  $('item_list').add(new Element('option', {value:item_id, selected:true}), 0);

  event.stop();
  return false;
}

function select_user_share() {
  var modal_content = (new Element('div')).update("<b>Select the user(s) you want to share with below</b><hr/>");
  modal_content.insert({bottom: user_share_list});
  modal_content.insert({bottom: '<hr/><input type="button" value="Okay" onclick="javascript:Modalbox.hide()"/>'});
  Modalbox.show(modal_content, {transitions:false, title:"Select Users"});
  user_share_list_all.observe('change', update_user_share_list);
}

function update_user_share_list(ev) {
  $('user_share_list').innerHTML = ""; //remove all the users on the real form
  $A(ev.target.selectedOptions).each(function(opt) {
    $('user_share_list').add(opt.clone()); // add a clone of each of them back
  });
}

function form_submitter() {
  $('user_share_list').className = "";
  $A($('user_share_list').options).each(function(opt) { opt.selected = true });
  return true;
}
