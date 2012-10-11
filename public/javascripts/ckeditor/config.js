/*
Copyright (c) 2003-2012, CKSource - Frederico Knabben. All rights reserved.
For licensing, see LICENSE.html or http://ckeditor.com/license
*/

CKEDITOR.editorConfig = function( config )
{
	// Define changes to default configuration here. For example:
	config.language = 'en';
	config.uiColor = '#9AB8F3';
    //config.enterMode = 2;
    //config.forceEnterMode = true;
    //config.shiftEnterMode = 1;
    config.basicEntities = false;
    config.entities_processNumerical = true;
    config.entities_additional = 'lt,gt,amp,apos,quot'
    config.entities_latin = false;
    config.entities_greek = false;
};
