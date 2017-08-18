// ==UserScript==
// @name       Di.fm Ad silencer
// @namespace  http://qmegas.info/difm
// @version    3.0
// @description  Silence ads on di.fm radio
// @include    http://*.di.fm/*
// @include    https://*.di.fm/*
// @include    https://*.classicalradio.com/*
// @include    https://*.radiotunes.com/*
// @include    https://*.jazzradio.com/*
// @include    https://*.rockradio.com/*
// @copyright  Megas (qmegas.info), And (and.webdev[at]gmail.com)
// @grant	   none
//
// ==/UserScript== panel-ad

(function(){
	// Adjust by your needs
	var config = {
		'checkInterval': 250
	};

	class AbstractPlayer {
		isApplicable() { return false; }
		isAdv() { return false; }
		isMuted() { return !!this.muted; }
		mute() {}
		unmute() {}
	}

	var players = window.$advSilencers = [

		// New player
		(function() {
			class Player extends AbstractPlayer {

				isApplicable() {
					return !!$('#webplayer-region .progress')[0];
				}

				initialize() {
					if (this.isApplicable()) {
						var container = $('#webplayer-region');

						this.bar = container.find('.progress');
						this.title = container.find('.track-title');
						this.volume = container.find('a.ico.volume');
					}
				}

				isAdv() {
					if (!this.title) return false;

					return !!this.bar.find('.bar.animated').length ||
						this.title.find('.sponsor').length ||
						this.title.text().toLowerCase() == 'di.fm'
						;
				}

				mute() {
					if (!this.muted) {
						this.volume.click();
						this.muted = true;
					}
				}

				unmute() {
					if (this.muted) {
						this.volume.click();
						this.muted = false;

					}
				}
			}

			return new Player();
		})(),

		// Legacy player
		(function() {
			class Player extends AbstractPlayer {

				isApplicable() {
					return !!$('#webplayer-region #toolbar-container a.ico.volume')[0];
				}

				initialize() {
					if (this.isApplicable()) {
						var container = this.container = $('#webplayer-region');

						this.volume = container.find('#toolbar-container a.ico.volume');
					}
				}

				isAdv() {
					if (!this.container) return false;

					var el = this.container.find('#panel-ad, #panel-feedback .forced');
					if (!el.length) {
						return false;
					}

					if (parseInt(el.css('top')) < 0) {
						return true;
					}

					return false;
				}

				isMuted() {
					return !!this.volume.hasClass('icon-mute');
				}

				mute() {
					if (!this.isMuted()) {
						this.volume.click();
						this.muted = true;
					}
				}

				unmute() {
					if (this.isMuted()) {
						this.volume.click();
						this.muted = false;

					}
				}
			}

			return new Player();
		})()
	];

	function init() {
		if (!initVars()) {
			setTimeout(init, 250);
		}
	}

	function initVars(){
		var player = false;

		for (var i = 0; i < players.length; i++) {
			if (players[i].isApplicable()) {
				players[i].initialize();
				player = players[i];
			}
		}
		if (!player) {
			return false;
		}

		var muted = player.isMuted();
		setInterval(function() {
			// console.log('State: isAdv ' + player.isAdv() + ', isMuted ' + player.isMuted());
			
			if (player.isAdv()) {
				if (!muted) {
					player.mute();
					muted = player.isMuted();
				}
			}
			else {
				if (muted) {
					player.unmute();
					muted = !player.isMuted();
				}
			}
		}, config.checkInterval);

		return true;
	}

	$(init);
})();
