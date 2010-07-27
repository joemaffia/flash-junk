package {
	import flash.display.Sprite;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
    import flash.events.Event;
    import fl.controls.RadioButton;
    import fl.controls.RadioButtonGroup;
	
	public class Question extends Sprite {  
		private var _question:String;  
		private var _questionSkill:String;
		private var _mod:int;
		private var _totalGroupQuestions:int;
		private var _totalGroup:int;
		private var _pageNum:int;
		private var _parentSection:int;
		private var _parentGroup:int;
		private var _answerNum:int;
		private var _answer:Array;
		//if -1 no RadioBox is selected, otherwise tha value is the question score
		private var theUserAnswer:int = -1;
		private var radioButtonChosed:int;
		private var numberField:TextField;
		private var questionField:TextField;
		private var answerScore:int;
		private var answerText:String;
		
		//variables for positioning:
        private var questionX:int = 315;
        private var questionY:int = 90;
        private var answerX:int = 333;
        private var answerY:int = 125;
        private var spacing:int = 20;
		  
		// The Question constructor  
		public function Question(question:String, questionSkill:String, mod:int, totalGroupQuestions:int, pageNum:int, parentSection:int, parentGroup:int, answerNum:int, answer:Array)  {  
			// Text Format
			var format12:TextFormat = new TextFormat();
			format12.font = "_sans";
			format12.color = 0x333333;
			format12.size = 12;
			
			var format11:TextFormat = new TextFormat();
			format11.font = "_sans";
			format11.color = 0x333333;
			format11.size = 11;
			
			// setting the global attributes to the incoming variables  
			_question = question;  
			_questionSkill = questionSkill;
			_mod = mod;
			_totalGroupQuestions = totalGroupQuestions;
			_pageNum = pageNum;
			_parentSection = parentSection;
			_parentGroup = parentGroup;
			_answerNum = answerNum;
			_answer = answer;
			
			
			switch(_mod) {
				case 0: questionY = questionY; answerY = answerY; break;
				case 1: questionY = questionY+130; answerY = answerY+130; break;
				case 2: questionY = questionY+260; answerY = answerY+260; break;
			}
			
			numberField = new TextField();
			numberField.htmlText = "<b>" + (_pageNum +1)+ "</b>" + ".";
			numberField.autoSize = TextFieldAutoSize.CENTER;
			numberField.x = questionX;
            numberField.y = questionY;
			numberField.setTextFormat(format12);
			addChild(numberField);
			
			questionField = new TextField();
			questionField.text = _question;
			questionField.autoSize = TextFieldAutoSize.LEFT;
			questionField.wordWrap = true;
			questionField.x = questionX+20;
			questionField.y = questionY;
			questionField.setTextFormat(format12);
			questionField.width = 285;
			addChild(questionField);
			//trace(questionField.height);
			//trace("answer:"+_answer);
			
			//create and position the radio buttons (answers):
            var myGroup:RadioButtonGroup = new RadioButtonGroup("group1");
            myGroup.addEventListener(Event.CHANGE, changeHandler);
            for(var i:int = 0; i < _answerNum; i++) {
                
				var rb:RadioButton = new RadioButton();
				rb.textField.autoSize = TextFieldAutoSize.LEFT;
				//rb.textField.border = true;
				//rb.textField.wordWrap = true;
				//rb.width = 200;
				//rb.setSize(100, 0);
				//rb.textField.numLines = 2;
				rb.setStyle("textFormat", format11);
				rb.label = _answer[i].substring(2);
                rb.group = myGroup;
                rb.value = i+":"+_answer[i].substring(0,1);
                rb.x = answerX;
                rb.y = questionY+5+questionField.height + (i * spacing);
				//rb.width = 50;
                addChild(rb);
				//trace(rb.width);
				
				/*
				var rb:RadioButton = new RadioButton();
				var lbl:TextField = new TextField();
				lbl.setTextFormat(format11);
				lbl.autoSize = TextFieldAutoSize.LEFT;
				lbl.wordWrap = true;
				lbl.text = _answer[i].substring(2);
				lbl.width =  200;
				rb.group = myGroup;
				rb.label="";
				rb.value = i+":"+_answer[i].substring(0,1);
                rb.x = answerX;
				lbl.x = answerX+20;
				
				var rightSpace:int = (lbl.height == spacing ? spacing*i : lbl.height*i);
                
				rb.y = questionY+5+questionField.height + (rightSpace);
				lbl.y = questionY+5+questionField.height + (rightSpace);
				trace(i+" : "+rightSpace);
				addChild(rb);
				addChild(lbl);
				*/
            }
		}  
		
		private function changeHandler(event:Event) {
			theUserAnswer = event.target.selectedData.substring(2);
			radioButtonChosed = event.target.selectedData.substring(0,1);
        }
		
		// Get fuctions 
		public function get question():String {
			return _question;  
		}
		public function get questionSkill():String {
			return _questionSkill;  
		}
		public function get parentSection():int {
			return _parentSection;  
		}
		public function get parentGroup():int {
			return _parentGroup;  
		}
		public function get totalGroupQuestions():int {
			return _totalGroupQuestions;  
		}
		public function get totalGroup():int {
			return _totalGroup;  
		}
		public function get pageNum():int {
			return _pageNum;  
		}
		public function get answerNum():int {
			return _answerNum;  
		}
		public function get answer():Array {
			return _answer;  
		}
        public function get userAnswer():int {
            return theUserAnswer;
        }
		public function get buttonChosed():int {
            return radioButtonChosed;
        }
	}  
}