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
	var $bar, $title, $volume, muted = false;

	function init() {
		if (!initVars()) {
			setTimeout(init, 250);
		}
	}

	function initVars(){
		$bar = $('#webplayer-region .progress');
        $title = $('#webplayer-region .track-title');
		if (!$bar.length) {
			return false;
		}

		$volume = $('#webplayer-region .settings-region a.ico.volume');
		setInterval(checkState, 1000);

		return true;
	}

	function checkState() {
		var isAdv = ($bar.find('.bar.animated').length || $title.find('.sponsor').length);
		 // console.log('State: isAdv ' + isAdv + ', isMuted ' + muted);

		if (isAdv) {
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
