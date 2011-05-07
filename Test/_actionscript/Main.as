//
//  Main Application Controller (using TextMate)
//
//	This file will load the XML and scan through it to grab all the different paramenters/values
//	adding them to our Question.as class that will contain all the questions, answers etc. etc.
//	The rest of the code will dynamically add components on the stage (Button etc.) and do all the logic.
//  
//	
//  Created by Joe Maffia on 02-09-2008.
//  Copyright (c) 2008. All rights reserved.
//
package {
	import flash.utils.Timer;
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.external.ExternalInterface; 
	import flash.net.navigateToURL;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.net.URLRequestMethod;
	import flash.net.URLLoaderDataFormat;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	import fl.motion.Color;
	import flash.geom.Transform;
	
	import fl.controls.Button;
	import fl.containers.UILoader;
	import fl.controls.TextArea;
	import fl.controls.ProgressBar;
	import fl.controls.ProgressBarMode;
	import com.afcomponents.events.AFComponentEvent;
	import player.*;
	
	public class Main extends Sprite {
		
		private var loader:URLLoader = new URLLoader();
		private var xml:XML;
		//the buttons:
        private var prevButton:Button;
        private var nextButton:Button;
		//scoring and messages:
        private var score:int = 0;
        private var statusTxt:TextField = new TextField();
		//imageLoader
		private var imageLoader:UILoader = new UILoader();
		private var imageX:int = 55;
		private var imageY:int = 155;
		private var myProgressBar:ProgressBar = new ProgressBar();
		//instruction Text
		private var instructionTxt:TextArea = new TextArea();
		private var instructionX:int = 5;
		private var instructionY:int = 5;
		//TextArea
		private var textArea:TextArea = new TextArea();
		private var textX:int = 20;
		private var textY:int = 90;
		//MP3 Player
		private var mp3:MusicPlayer = new MusicPlayer();
			
		// Create a new Timer object with a delay of 3000 ms
		// this timer is used to hide the DescrPane after a bit
		private var myTimer:Timer = new Timer(3000, 1);
		
		public var imgsPath:String;
		public var mediaPath:String;
		public var levelBeginner:int;
		public var levelElementary:int;
		public var levelIntermediate:int;
		public var levelAdvanced:int;
		public var instruction:Array = new Array();
		public var groupInfo:Array = new Array();
		private var testQuestions:Array;
		private var testQuestionsPage:Array = new Array( new Array(), new Array(), new Array());
		
		public var totalQuestion:int = 0;
		private var currentQuestion:Question;
        private var currentIndex:int = 0;
		private var pageIndex:int = 0;
		private var row:int = 0;
		private var minCurrentIndex:int = 0;
		private var whichAnswer:Array = new Array();
		private var levelScore:Array = new Array();
		private var totalLevelScore:Array = new Array();
		
		private var correctQuestionLevel:Array = new Array();
		private var blankQuestionLevel:Array = new Array();
		
		private var pagePerSection:Array = new Array();
		
		private var product:String;
		private var testid:String;
		private var memberID:String;
		private var email:String;
										 
		public function Main():void {
			//color changing of the main slide
			//color
			var c:Color = new Color();
			c.setTint(root.loaderInfo.parameters.colorChange, .6);
			
			mc_slide.transform.colorTransform = c;
			
			testQuestions = new Array();
			//use for local test
			//var url:String = "test_with_audio.xml";
			var url:String = root.loaderInfo.parameters.contentXML;
			
			// will get the product, memberid, email and testid so if the session expires 
			// we'lls till have this important info
			var iState:String = root.loaderInfo.parameters.iState;
			var iStateArray = iState.split(",");
			product = iStateArray[0];
			testid = iStateArray[1];
			memberID = iStateArray[2];
			email = iStateArray[3];
			
			// add a listener for the loader
			loader.addEventListener(Event.COMPLETE, onLoaderComplete);
			// load the XML and set all the variables
			if ( url.substr(0,4) != "file" ) {
				var d:Date = new Date();
				url += "?cachebuster=" + d.getTime();
			}
			loader.load(new URLRequest(url));
		}
		
		private function onLoaderComplete(e:Event):void {
			onXMLLoaded(e);
			createInfoComponents();
			createButtons();
			addAllQuestions();
			hideAllQuestions();
			//buildnewArray();
			firstQuestion();
		}
		
		private function onXMLLoaded(e:Event):void	{

			xml = new XML(e.target.data);
			xml.ignoreWhitespace = true;
			
			// imgs and media path
			imgsPath = xml.parameter.text()[0];
			mediaPath = xml.parameter.text()[1];
			// get the different levels
			levelBeginner = xml.level.attribute("upper")[0];
			levelElementary = xml.level.attribute("upper")[1];
			levelIntermediate = xml.level.attribute("upper")[2];
			levelAdvanced = xml.level.attribute("upper")[3];
			//get the instruction text
			//var g:int = 0;
			var group:int = -1;
			var col:int = -1;
			for (var s:int = 0; s < xml.section.length(); s++) {
				instruction[s] = xml.section.instruction[s].children();
				levelScore[s] = 0;
				totalLevelScore[s] = 0;
				//get all the questions and relative elements
				//trace('group.length:'+xml.section[s].group.length());
				for (var g:int = 0; g < xml.section[s].group.length(); g++) {
					group++;
					// first get the info tag
					if (xml.section.group[group].info.audio != undefined) {
						//trace("Group:"+group+":"+xml.section.group[group].info.audio.attribute("src")+"|"+xml.section.group[group].info.audio.attribute("label")+"|"+xml.section.group[group].info.image.attribute("src"));
						groupInfo[group] = xml.section.group[group].info.audio.attribute("src")+"|"+xml.section.group[group].info.audio.attribute("label")+"|"+xml.section.group[group].info.image.attribute("src");
					} else if (xml.section.group[group].info.image != undefined) {
						//trace("Group:"+group+":"+xml.section.group[group].info.image.attribute("src"));
						groupInfo[group] = xml.section.group[group].info.image.attribute("src");
					} else if (xml.section.group[group].info.text != undefined) {
						//trace("Group:"+group+":"+xml.section.group[group].info.text.children());
						groupInfo[group] = xml.section.group[group].info.text.children();
					}
					
					//then get the page
					//trace('question.length:'+xml.section.group[group].page.question.length());
					for (var p:int = 0; p < xml.section.group[group].page.question.length(); p++) {
						var mod:int = p%3;
						//to have a short reference
						var totalGroupQuestions = xml.section.group[group].page.question.length();
						var parentSection = s;
						var parentGroup = group;
						var answerNum = xml.section.group[group].page[p].question.answer.option.length();
						
						var eachAnswer:Array = new Array();
						
						//get all the different answers for each question
						
						for (var x:int = 0; x < answerNum; x++) {
							var score = 0;
							if (xml.section.group[group].page[p].question.answer.option[x].attribute("score")+"" != "") {
								score = xml.section.group[group].page[p].question.answer.option[x].attribute("score")+"";
								totalLevelScore[s] = totalLevelScore[s]+Number(score);
							}
							eachAnswer[x] = score + "|" + xml.section.group[group].page[p].question.answer.option[x].text(); 
						}
						
						//finally set the Question Object with all the questions, answers & score
						testQuestions.push(new Question(xml.section.group[group].page[p].question.text(),xml.section.group[group].page[p].question.attribute("skill"), mod, totalGroupQuestions, totalQuestion, parentSection, parentGroup, answerNum, eachAnswer));
						totalQuestion++;
						
						pagePerSection[s]= xml.section[s].group.page.question.length();
						// these two lines populate a new multidimensional array
						// each col of this array contain all the questions for that specific page
						/*
							   0  1  2  3   4   5  
							0 q1 q4 q6 q9  q12 q15
							1 q2 q5 q7 q10 q13 q16
							2 q3    q8 q11 q14 q17
						*/
						if (mod == 0) col++;
						testQuestionsPage[mod][col] = testQuestions[totalQuestion-1];
					}				
				}
			}
		}
		private function createInfoComponents() {
			myTimer.addEventListener("timer", descrPaneHide);
			
			// Text Format
			var format:TextFormat = new TextFormat();
			format.font = "_sans";
			format.color = 0x4B4B4B;
			format.size = 12;
			
			//instruction
			instructionTxt.x = instructionX;
			instructionTxt.y = instructionY;
			instructionTxt.width = stage.width - 10;
			instructionTxt.height = 60;
			instructionTxt.condenseWhite = true;
			instructionTxt.editable = false;
			instructionTxt.setStyle("textFormat", format);
			instructionTxt.visible = false;
			addChild(instructionTxt);
			
			//groupInfo - image
			imageLoader.x = imageX;
			imageLoader.y = imageY;
			imageLoader.width = 186;
			imageLoader.height = 186;
			imageLoader.visible = false;
			addChild(imageLoader);

			//groupinfo - text
			textArea.condenseWhite = true;
			textArea.editable = false;
			textArea.horizontalScrollPolicy = "off";
			textArea.x = textX;
			textArea.y = textY;
			textArea.width = 270;
			textArea.height = 380;
			textArea.setStyle("textFormat", format);
			textArea.visible = false;
			addChild(textArea);
			
			//MP3 Player
			mp3.x = 15;
			mp3.y = 350;
			mp3.visible = false;
			addChild(mp3);
			
			myProgressBar.mode = ProgressBarMode.MANUAL;
			myProgressBar.move(75, 250);
			myProgressBar.visible = false;
			addChild(myProgressBar);
			
			myDescrPane.addEventListener(AFComponentEvent.SHOW, descrPaneShow);
		}
		
		private function createButtons() {
            // Button Format
			var format:TextFormat = new TextFormat();
			format.font = "_sans";
			format.color = 0xFFFFFF;
			format.size = 11;
			format.bold = true;
			
			var yPosition:Number = stage.stageHeight - 28;

            prevButton = new Button();
			prevButton.setStyle("textFormat", format);
            prevButton.label = "Previous";
            prevButton.x = 20;
            prevButton.y = yPosition;
			prevButton.width = 80;
            prevButton.addEventListener(MouseEvent.CLICK, prevHandler);
			addChild(prevButton);

            nextButton = new Button();
			nextButton.setStyle("textFormat", format);
            nextButton.label = "Next";
            nextButton.x = stage.stageWidth - nextButton.width;
            nextButton.y = yPosition;
			nextButton.width = 80;
            nextButton.addEventListener(MouseEvent.CLICK, nextHandler);
            addChild(nextButton);
        }

		private function addAllQuestions() {
            for(var i:int = 0; i < totalQuestion; i++) {
                addChild(testQuestions[i]);
            }
		}
		private function hideAllQuestions() {
            for(var i:int = 0; i < totalQuestion; i++) {
                testQuestions[i].visible = false;
            }
		}
		
		private function firstQuestion() {
			currentIndex = -1;
			for (row = 0; row < 3; row++ ) {
				if (testQuestionsPage[row][pageIndex]+"" != 'undefined') {
					testQuestionsPage[row][pageIndex].visible = true;
					currentIndex++;
				}
			}
			minCurrentIndex = currentIndex;
			updateInfo();
        }
     	
		private function updateInfo() {
			instructionTxt.visible = true;
			instructionTxt.htmlText = instruction[testQuestions[currentIndex].parentSection];
			
			var string:String = groupInfo[testQuestions[currentIndex].parentGroup];
			var groupInfoArray:Array = string.split("|");
			if (groupInfoArray.length > 1) {
				if (groupInfoArray[2].search(".gif") != -1 || groupInfoArray[2].search(".jpg") != -1 || groupInfoArray[2].search(".jpeg") != -1 || groupInfoArray[2].search(".png") != -1) {
					imageLoader.source = imgsPath + groupInfoArray[2];
					imageLoader.load();
					imageLoader.addEventListener(ProgressEvent.PROGRESS, progressHandler);
					imageLoader.addEventListener(Event.COMPLETE, completeHandler);
					imageLoader.visible = true;
				} 
				if (groupInfoArray[0].search(".mp3") != -1) {
					mp3.visible = true;
					mp3.loadSong(mediaPath+groupInfoArray[0]);
					trace(mediaPath+groupInfoArray[0])
				}				
				if (groupInfoArray[1] != "") {
					textArea.htmlText = groupInfoArray[1];
					textArea.visible = true;
				}
			} else {
				mp3.visible = false;
				mp3.stopSong();
				if (groupInfoArray[0].search(".gif")!= -1 || groupInfoArray[0].search(".jpg") != -1 || groupInfoArray[0].search(".jpeg") != -1 || groupInfoArray[0].search(".png") != -1) {
					textArea.visible = false;
					imageLoader.source = imgsPath + groupInfoArray[0];
					imageLoader.load();
					imageLoader.addEventListener(ProgressEvent.PROGRESS, progressHandler);
					imageLoader.addEventListener(Event.COMPLETE, completeHandler);
					imageLoader.visible = true;
				} else {
					imageLoader.visible = false;
					textArea.htmlText = groupInfoArray[0];
					textArea.visible = true;
				}
			}
		}
		
		function progressHandler(event:ProgressEvent):void {
			myProgressBar.visible = true;
			var uiLdr:UILoader = event.currentTarget as UILoader;
			var kbLoaded:String = Number(uiLdr.bytesLoaded / 1024).toFixed(1);
			var kbTotal:String = Number(uiLdr.bytesTotal / 1024).toFixed(1);
			//trace(kbLoaded + " of " + kbTotal + " KB" + " (" + Math.round(uiLdr.percentLoaded) + "%)");
			myProgressBar.setProgress(event.bytesLoaded, event.bytesTotal);
		}
		function completeHandler(event:Event):void {
			myProgressBar.visible = false;
		}

		private function prevHandler(event:MouseEvent) {
            if(currentIndex > minCurrentIndex) {
				var currentGroup = testQuestions[currentIndex].parentGroup;
				
				//hide questions
				for (row = 0; row < 3; row++ ) {
					if (testQuestionsPage[row][pageIndex]+"" != 'undefined') {
						testQuestionsPage[row][pageIndex].visible = false;	
						currentIndex--;
					}
				}
				pageIndex--;
				for (row = 0; row < 3; row++ ) {
					if (testQuestionsPage[row][pageIndex]+"" != 'undefined') {
						testQuestionsPage[row][pageIndex].visible = true;
						
					}
				}
				//trace('page:'+pageIndex+' currentIndex:'+currentIndex);
				//update Info
				if (currentGroup != testQuestions[currentIndex].parentGroup) {
					updateInfo();
				}
            } else {
                myDescrPane.show();
				myDescrPane.content = "This is the first question, there are no previous ones !";
            }
			
        }
		//var runTimes:int=0;
		var newIndex:int;
		var lastPrevIndex:int;
		
		private function nextHandler(event:MouseEvent) {
            if(currentIndex < (testQuestions.length - 1)) {
				var previousGroup = testQuestions[currentIndex].parentGroup;
				
 				//hide questions
				for (row = 0; row < 3; row++ ) {
					if (testQuestionsPage[row][pageIndex]+"" != 'undefined') testQuestionsPage[row][pageIndex].visible = false;	
				}
				pageIndex++;
				for (row = 0; row < 3; row++ ) {
					if (testQuestionsPage[row][pageIndex]+"" != 'undefined') {
						testQuestionsPage[row][pageIndex].visible = true;
						currentIndex++;
					}
				}
				//trace('page:'+pageIndex+' currentIndex:'+currentIndex);
				//update Info
				if (previousGroup != testQuestions[currentIndex].parentGroup) {
					updateInfo();
				}
            } else {
                //myDescrPane.content = "That's all the questions! Click Finish to Score, or Previous to go back";
            	//myDescrPane.show();
				prevButton.visible = false;
	            nextButton.visible = false;
				//textArea.visible = false;
	            //hideAllQuestions();
	            computeScore();
			}
        }

		function descrPaneShow(event:AFComponentEvent) {
			// Start the timer
			myTimer.start();
		}
		function descrPaneHide(event:TimerEvent) {
			//trace("Timer fired " + myTimer.currentCount + " times.");
			myDescrPane.hide();
		}

		private function computeScore() {
			var total:int = 0;
			for (var pps:int = 0; pps < pagePerSection.length; pps++) {
				var bql:int = 0;
				var cql:int = 0;
				total += pagePerSection[pps];
				blankQuestionLevel[pps] = 0;
				for (var pps2:int; pps2 < total; pps2++) {
					if (testQuestions[pps2].userAnswer == -1) {
						blankQuestionLevel[pps] = ++bql;
						whichAnswer[pps2] = -1
					} else whichAnswer[pps2] = testQuestions[pps2].buttonChosed;
					
					if(testQuestions[pps2].userAnswer != -1 && testQuestions[pps2].userAnswer != 0) {
						levelScore[pps] += testQuestions[pps2].userAnswer;
						correctQuestionLevel[pps] = ++cql;
					} else correctQuestionLevel[pps] = cql;
				}
				score += Number(levelScore[pps]);
			}
			
			//trace("totalLevelScore:"+totalLevelScore);
			//trace("totalScore:"+score);
			//trace("blankQuestionLevel:"+blankQuestionLevel);
			//trace("correctQuestionLevel:"+correctQuestionLevel);
			//trace(whichAnswer);
			//trace(levelScore);
			
			//score = levelScore[0]+levelScore[1];
					
			var yourLevel:String = new String();
			if (score <= levelBeginner) {
				yourLevel = "0";
			} else if (score <= levelElementary) {
				yourLevel = "1";	
			} else if (score <= levelIntermediate) {
				yourLevel = "2";
			} else if (score <= levelAdvanced) {
				yourLevel = "3";
			}
			
            //trace("Total Score: " + score);
			//trace("yourLevel: "+yourLevel);
			//trace("levelScore:"+levelScore);
			//trace("whichAnswer:"+whichAnswer);
			//trace("You answered " + score + " correct out of " + testQuestions.length + " questions. Your level is:" + yourLevel);
			//ExternalInterface.call("foo", whichAnswer);
			
			var variables:URLVariables = new URLVariables();
			variables.sent = 1;
			variables.totalScore = score;
			variables.totalLevelScore = totalLevelScore;
			variables.yourLevel = yourLevel;
			variables.levelScore = levelScore;
			variables.whichAnswer = whichAnswer;
			variables.blankQuestionLevel = blankQuestionLevel;
			variables.correctQuestionLevel = correctQuestionLevel;
			variables.pagePerSection = pagePerSection;

			variables.product = product;
			variables.testid = testid;
			variables.memberID = memberID;
			variables.email = email;
			
			var request:URLRequest = new URLRequest(root.loaderInfo.parameters.postPage);
			request.method = "POST";
			request.data = variables;
			try {          	
				navigateToURL(request, "_self");
			}
			catch (e:Error) {
				// handle error here
			}
        }
        
	}	
}