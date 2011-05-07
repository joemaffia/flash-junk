/*
	CASA Framework for ActionScript 2.0
	Copyright (C) 2007  CASA Framework
	http://casaframework.org
	
	This library is free software; you can redistribute it and/or
	modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.
	
	This library is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	Lesser General Public License for more details.
	
	You should have received a copy of the GNU Lesser General Public
	License along with this library; if not, write to the Free Software
	Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
*/

import org.casaframework.util.NumberUtil;
import org.casaframework.util.StringUtil;

/**
	@author David Nelson
	@author Aaron Clinger
	@version 02/12/07
*/

class org.casaframework.util.LoremIpsum {
	private static var $words:Array = new Array('lorem', 'ipsum', 'dolor', 'sit', 'amet', 'consectetuer', 'adipiscing', 'elit', 'nam', 'imperdiet', 'dignissim', 'erat', 'mauris', 'ut', 'pellentesque', 'habitant', 'morbi', 'tristique', 'senectus', 'et', 'netus', 'malesuada', 'fames', 'ac', 'turpis', 'egestas', 'phasellus', 'sem', 'metus', 'lacinia', 'facilisis', 'at', 'sagittis', 'vel', 'felis', 'aenean', 'bibendum', 'in', 'enim', 'nulla', 'sed', 'ante', 'scelerisque', 'aliquet', 'facilisi', 'aliquam', 'velit', 'vitae', 'tellus', 'massa', 'etiam', 'hendrerit', 'rutrum', 'orci', 'nibh', 'fringilla', 'posuere', 'mi', 'praesent', 'interdum', 'risus', 'arcu', 'donec', 'auctor', 'dui', 'tempus', 'nec', 'id', 'laoreet', 'blandit', 'ligula', 'eu', 'dapibus', 'tincidunt', 'nunc', 'lectus', 'integer', 'curabitur', 'a', 'ultricies', 'quis', 'suscipit', 'eleifend', 'augue', 'congue', 'eros', 'non', 'sapien', 'neque', 'vestibulum', 'nonummy', 'leo', 'ornare', 'vehicula', 'eget', 'tempor', 'magna', 'suspendisse', 'placerat', 'mattis', 'luctus', 'lacus', 'duis', 'venenatis', 'porta', 'urna', 'vivamus', 'nisl', 'proin', 'sollicitudin', 'pulvinar', 'quam', 'maecenas', 'lobortis', 'pharetra', 'purus', 'pretium', 'mollis', 'cum', 'sociis', 'natoque', 'penatibus', 'magnis', 'dis', 'parturient', 'montes', 'nascetur', 'ridiculus', 'mus', 'fusce', 'est', 'ultrices', 'feugiat', 'iaculis', 'nisi', 'sodales', 'vulputate', 'tortor', 'accumsan', 'commodo', 'faucibus', 'justo', 'volutpat', 'porttitor', 'gravida', 'nullam', 'molestie', 'condimentum', 'euismod', 'elementum', 'odio');
	
	
	/**
		Creates a defined amount of placeholder words.
		
		@amount The amount of words.
		@return Returns a string comprised of randomized dummy text.
	*/
	public static function generateWords(amount:Number):String {
		var l:Number = LoremIpsum.$words.length;
		var r:String = StringUtil.toTitleCase(LoremIpsum.$words[NumberUtil.randomInteger(0, l)]);
		
		amount--;
		
		while (amount--)
			r += ' ' + LoremIpsum.$words[NumberUtil.randomInteger(0, l)];
		
		return r;
	}
	
	/**
		Creates a defined amount of placeholder sentences. Sentence length varies between four and ten words.
		
		@amount The amount of sentences.
		@return Returns a string comprised of randomized dummy text.
	*/
	public static function generateSentences(amount:Number):String {
		var r:String = '';
		
		while (amount--)
			r += LoremIpsum.generateWords(NumberUtil.randomInteger(4, 10)) + '. ';
		
		return r.slice(0, -1);
	}
	
	/**
		Creates a defined amount of placeholder paragraphs. Paragraph length varies between four and fifteen sentences.
		
		@amount The amount of paragraphs.
		@return Returns a string comprised of randomized dummy text.
	*/
	public static function generateParagraphs(amount:Number):String {
		var t:String = '';
		
		while (amount--)
			t += LoremIpsum.generateSentences(NumberUtil.randomInteger(4, 15)) + '\r\r';
		
		return t;
	}
	
	private function LoremIpsum() {} // Prevents instance creation
}