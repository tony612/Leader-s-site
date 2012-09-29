
$(document).ready(function(){	
			$ = jQuery;
			$("#slider").easySlider({
				auto: true, 
				continuous: true,
				numeric: true
			});
			
			$('.jquery_tabs').accessibleTabs({
			      fx: 'fadeIn',
			      syncheight: true,
			      tabbody: '.tab-content'
		       });
		});
