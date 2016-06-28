// ==UserScript==
// @name       Di.fm Ad silencer
// @namespace  http://qmegas.info/difm
// @version    2.0
// @description  Silence ads on di.fm radio
// @include    http://*.di.fm/*
// @copyright  Megas (qmegas.info)
// @grant	   none
// 
// ==/UserScript==

(function(){
	var $bar, $volume, muted = false;
	
	function init() {
		if (!initVars()) {
			setTimeout(init, 1000);
		}
	}
	
	function initVars(){
		$bar = $('#webplayer-region .progress');
		if ($bar.length == 0) {
			return false;
		}
		
		$volume = $('#webplayer-region .settings-region a.ico.volume');
		setInterval(checkState, 1000);
	
		return true;
	}
	
	function checkState() {
		var isAnimated = ($bar.find('.bar.animated').length > 0);
		//console.log('Is animated: ', isAnimated);
		//console.log('Is muted: ', muted);
		
		if (isAnimated) {
			if (!muted) {
				$volume.click();
				//console.log('Click');
				muted = true;
			}
		} else {
			if (muted) {
				$volume.click();
				//console.log('Click');
				muted = false;
			}
		}
	}
	
	$(function(){
		init();
	});
})();
