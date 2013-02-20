var new_access_token_showing;
var user_share_list;

function on_view_items_loaded() {
  $$('a.item').each(function(item) {
    item.observe('click', add_item);
  });
  $$('img.item').each(function(item) {
    if(item.hasClassName('folder')) {
      item.observe('click', function() {
        // we have to get the href this way so that the browser doesn't be a wise ass and put the proto and host in there too.
        window.location.hash = item.up().getAttribute('href').substring(1);
        load_view_items();
        event.stop();
        return false;
      });
      item.observe('contextmenu', function() {
        // get the list of IDs that start with this
      });
    }
    else {
      item.observe('contextmenu', add_item);
    }
  });
}

document.observe('dom:loaded', function() {
  if(window.location.href.match(/\/view/)) {
    if(!window.location.hash || window.location.hash == "") {
      console.info("setting default hash and hoping that triggers the items to load");
      window.location.hash = "#view";
    }
    console.info("loading items from current hash");
    load_view_items();

    user_share_list = Element.remove('user_share_list_all'); // .remove() is on <select ...> tags

    new_access_token_showing = $('new_access_token').innerHTML;
    $('new_access_token').update("Right-click on an item to share it...");
  }

  $$('.xhr').each(function(xhr_link) {
    var target = $(xhr_link.dataset.target);
    xhr_link.observe('click', function(ev) {
      xhr_updater(xhr_link.href, $(target), on_view_items_loaded);
    });
  });
})

function xhr_updater(url, target, callback) {
  if( ! callback )
    callback = function() { console.log("XHR to", url, "finished"); }
  console.log("xhr link clicked, going to", url);
  new Ajax.Updater(target, url, {
    method: 'get',
    onComplete: callback,
  });
  target.update('Loading... <img src="/images/spinner.gif"/>');

  if(event && event.stop) event.stop();
  return false;
}

function load_view_items(url) {
  if(!url || typeof(url) != "string")
    url = '/' + window.location.hash.substring(1);
  xhr_updater(url, $('items'), on_view_items_loaded);
}

document.observe('hashchange', load_view_items);

function add_item(ev) {
  var item_id = this.dataset.id;
  var item_parent = $('item-'+item_id);
  var item_name = item_parent.dataset.name;
  
  if( new_access_token_showing ) {
    $('new_access_token').update(new_access_token_showing);
    $('user_share_button').observe('click', select_user_share);
    $$('form')[0].observe('submit', form_submitter);
    new_access_token_showing = null;
  }

  item_parent.remove().addClassName('selected');
  //$('items').insert({'top': item_parent});
  item_parent.getElementsByTagName('img')[0].setStyle({width:'100px', height:'100px'});
  $('shared_items').insert({'top': item_parent});
  
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
