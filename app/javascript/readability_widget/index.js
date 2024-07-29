// Loads widget on page
// initiates widget functionality (toggle button, on|off switches)
import './styles/widget.css';
import './styles/widget.scss';
import './styles/fonts/OpenDyslexic-Bold.otf';
import './styles/fonts/OpenDyslexic-Regular.otf';
import './styles/fonts/OpenDyslexic-Italic.otf';
// test
const raWidget = {

	// load widget to page
	init: function(){
		raWidget._paq = window._paq || [];
		
		fetch('/widget').then(function (response) {
		// fetch('http://local.lib.ncsu.edu/dev/readability-widget/widget.html').then(function (response) {
			// successful API call
			return response.text();
		}).then(function (html) {
			// HTML from response as text string
			// append to the end of the body element
			var b = document.body;
			b.insertAdjacentHTML("beforeend",html);

			// once widget has loaded enable event listener on button
			raWidget.toggle_widget();

			// // enable event listeners on toggles
			raWidget.add_listeners_to_toggles();

			// close when clicking outside widget area
			raWidget.close_on_click_outside_of_widget();

			// close when esc key pressed
			raWidget.close_on_escape();

			// hide widget when hide button pressed
			raWidget.set_hidden_event_listener();

			// check localstorage toggles
			raWidget.check_localstorage_toggles();
			
			// add analytics to html links
			raWidget.add_link_analytics();

			// finally show widget to users
			raWidget.show_widget_to_users();

		}).catch(function (err) {
			// something went wrong
			console.warn("Failed to load widget.html", err);
		});

	 },

	show_widget_to_users : function(){
		// bug where widget content padding was not computed right away. wait for padding to be computed before showing widget
		const padding_check = setInterval(function(){
			var widget_content = document.getElementById("widget-content");
			var widget_content_padding = window.getComputedStyle(widget_content, null).getPropertyValue('padding-left');
			if(widget_content_padding != '0px'){
				clearInterval(padding_check);
				raWidget.close_widget();
				// show widget
				document.getElementById('readability-widget').style.opacity = 1;
			}
		},100);
	},

	toggle_widget : function(e){
		// add event listener to widget button (toggle on|off)
		document.querySelector("#widget-toggle-button").addEventListener("click", function(e){
			var widget_element = document.getElementById('readability-widget');
			if(widget_element.classList.contains('closed')){
				raWidget.reveal_widget();
			}else{
				raWidget.close_widget();
			}
		});
	},
	// reveal widget to user
	reveal_widget : function(){
		var widget_element = document.getElementById('readability-widget');
		widget_element.classList.remove('closed');
		widget_element.classList.remove('widget-hidden');
		widget_element.classList.add('open');
		// set bottom of article to 0px
		widget_element.style.bottom = "0px";

		raWidget.set_widget_hidden_local_storage('false');

		raWidget.enable_internal_tabbing();

		// add analytics
		raWidget._paq.push(['trackEvent', 'Readability Widget', 'widget toggle', 'open']);
	},
	
	// hide widget (still revealing widget toggle button)
	close_widget : function(){

		var widget_element = document.getElementById('readability-widget');
		widget_element.classList.remove('open');
		widget_element.classList.add('closed');

		// set bottom of article to - height of the widget content
		var widget_content = document.getElementById("widget-content");

		widget_element.style.bottom = -(widget_content.offsetHeight) + "px";

		raWidget.disable_internal_tabbing();
	},

	/**
	 * Allows tabbing past readability widget when not open
	 */
	disable_internal_tabbing: function() {
		var all_internal_links = document.querySelectorAll('#widget-content a, #widget-content input, #widget-content button');
  
	  	all_internal_links.forEach(function (currentValue) {
		  currentValue.tabIndex = -1;
		});
	},
	
	/**
	 * Restores tabbing inside widget, when open
	 */
	enable_internal_tabbing: function() {
		var all_internal_links = document.querySelectorAll('#widget-content a, #widget-content input, #widget-content button');

		all_internal_links.forEach(function (currentValue) {
			currentValue.tabIndex = 0;
		});
	},

	// if click happens outside popover, close it
	close_on_click_outside_of_widget : function() {
		var widget_element = document.getElementById('readability-widget');
		const outside_click_listener = event => {
			if (!widget_element.contains(event.target) && !widget_element.classList.contains('closed')) {
				raWidget.close_widget();
			}
		}
		// add event listener to body
		document.addEventListener('click', outside_click_listener);
	},

	close_on_escape : function() {
		const escape_key_listener = event => {

			if(event.keyCode == 27) {
				raWidget.close_widget();
			}
		}
		document.addEventListener("keydown", escape_key_listener);
	},

	set_hidden_event_listener : function() {
		document.getElementById("hide-widget-button").addEventListener('click', function(e){
			raWidget.hide_widget();
		})
	},

	hide_widget : function(){
		raWidget.close_widget();
		// and hide it too
		var widget_element = document.getElementById('readability-widget');
		widget_element.classList.add("widget-hidden");

		// set widget localStorge 
		raWidget.set_widget_hidden_local_storage('true');

		// add analytics_exists
		raWidget._paq.push(['trackEvent', 'Readability Widget', 'widget toggle', 'hidden']);
	},

	check_localstorage_toggles : function(){
		// check if we should hide widget
		if(localStorage.widget_hidden == 'true'){
			raWidget.hide_widget();
		}

		// check for warm background
		if(localStorage.warm_background == 'true'){
			//document.body.style.backgroundColor = "#F5E4D1"; //peach
			const warm_overlay_el = document.createElement('div');
			warm_overlay_el.id = "readability-warm-overlay";
			document.body.appendChild(warm_overlay_el);
			document.getElementById("warm-background-toggle").checked = true;
		}

		// check for images
		if(localStorage.hide_all_images == 'true'){
			raWidget.hide_show_all_images('true');
			document.getElementById("hide-images-toggle").checked = true;
		}

		// check for dyslexic font storage
		if(localStorage.open_dyslexic_font == 'true'){
			document.body.classList.add("open-dyslexic");
			document.getElementById("open-dyslexic-font-toggle").checked = true;
		}

		// check for highlight links storage
		if(localStorage.highlight_links == 'true'){
			raWidget.hide_show_highlighted_links('true');
			document.getElementById("highlight-links-toggle").checked = true;
		}

	},

	set_widget_hidden_local_storage : function(value){
		localStorage.widget_hidden = value;
	},

	add_listeners_to_toggles : function(){
		// toggle background to a warm color and back to original color
		document.getElementById("warm-background-toggle").addEventListener('click', function(e){
			if(e.target.checked){
				//document.body.style.backgroundColor = "#F5E4D1"; //peach
				const warm_overlay_el = document.createElement('div');
				warm_overlay_el.id = "readability-warm-overlay";
				document.body.appendChild(warm_overlay_el);
				localStorage.warm_background = 'true';

				// add analytics
				raWidget._paq.push(['trackEvent', 'Readability Widget', 'warm background', 'on']);
			}else{
				//document.body.style.backgroundColor = "";
				document.getElementById("readability-warm-overlay").remove();
				localStorage.warm_background = 'false';

				// add analytics
				raWidget._paq.push(['trackEvent', 'Readability Widget', 'warm background', 'off']);
			}
		})

		document.getElementById("hide-images-toggle").addEventListener('click', function(e){
			if(e.target.checked){
				raWidget.hide_show_all_images('true');
			}else{
				raWidget.hide_show_all_images('false');
			}
		})

		document.getElementById("open-dyslexic-font-toggle").addEventListener('click', function(e){
			if(e.target.checked) {
				// make body font OpenDyslexic
				document.body.classList.add("open-dyslexic");

				// set local storage
				localStorage.open_dyslexic_font = 'true';

				// add analytics
				raWidget._paq.push(['trackEvent', 'Readability Widget', 'highlight dyslexic font', 'on']);

			} else {
				// // make font regular again
				document.body.classList.remove("open-dyslexic");

				// set local storage
				localStorage.open_dyslexic_font = 'false';

				// add analytics
				raWidget._paq.push(['trackEvent', 'Readability Widget', 'highlight dyslexic font', 'off']);
			}
		})

		document.getElementById("highlight-links-toggle").addEventListener('click', function(e){
			if(e.target.checked){
				raWidget.hide_show_highlighted_links('true');
				// add analytics
				raWidget._paq.push(['trackEvent', 'Readability Widget', 'highlight links', 'on']);
			}else{
				raWidget.hide_show_highlighted_links('false');
				// add analytics
				raWidget._paq.push(['trackEvent', 'Readability Widget', 'highlight links', 'off']);
			}		
		})
	},

	hide_show_all_images : function(value){
		/** get all images
		all_images = document.querySelectorAll("img");
		if(value == 'true'){
			for(i=0;i<all_images.length;i++){
				all_images[i].style.display = 'none';
			}
		}else if(value == 'false'){
			for(i=0;i<all_images.length;i++){
				all_images[i].style.display = '';
			}
		}*/
		if(value == 'true') {
			document.body.classList.add('readability-hide-images');
			// add analytics
			raWidget._paq.push(['trackEvent', 'Readability Widget', 'hide images', 'on']);
		} else {
			document.body.classList.remove('readability-hide-images');
			// add analytics
			raWidget._paq.push(['trackEvent', 'Readability Widget', 'hide images', 'off']);
		}
		localStorage.hide_all_images = value;
	},

	hide_show_highlighted_links : function(value){
		
		if(value == 'true'){
			document.body.classList.add('readability-highlight-links-on');

			// add analytics
			raWidget._paq.push(['trackEvent', 'Readability Widget', 'highlight links', 'on']);
		}else if(value == 'false'){
			document.body.classList.remove('readability-highlight-links-on');

			// add analytics
			raWidget._paq.push(['trackEvent', 'Readability Widget', 'highlight links', 'off']);
		}

		localStorage.highlight_links = value;
	},
	// add analytics to text links
	add_link_analytics : function(){
		document.getElementById('widget-feedback-link').addEventListener('click', function(e){
			// add analytics
			raWidget._paq.push(['trackEvent', 'Readability Widget', 'widget feedback link click']);
		})
	}
}

// once DOM is fully loaded, initialize widget
window.addEventListener('DOMContentLoaded', function(e) {
	raWidget.init();
});


