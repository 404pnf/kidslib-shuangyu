/* Generates book reader interface for plain HTML file */

var lines_number = 16;
//var line_height = 30;
var line_height = 30;
var scroll_step = lines_number * line_height;

var log;

//var localStorage = {};

$(function() {
		   //zh-chenjing
	$(".zh_btn").click(function(){
 		 $(".zh").css("visibility","visible");
 		 $(".en").css("visibility","hidden");
  });
	//en-chenjing
	$(".en_btn").click(function(){
 		 $(".en").css("visibility","visible");
 		 $(".zh").css("visibility","hidden");
  });
	//zh-chenjing
	$(".zhen_btn").click(function(){
  		$(".zh").css("visibility","visible");
 		$(".en").css("visibility","visible");
  });
  $('.ebook_content').wrapInner('<div id="book" />');
  function up() { $('#book').animate({scrollTop:"-="+scroll_step+"px"}, 0); 
  localStorage[window.location.href] = $('#book').scrollTop(); 
  }
  function down() { $('#book').animate({scrollTop:"+="+scroll_step+"px"}, 0); 
   
  localStorage[window.location.href] = $('#book').scrollTop();

  }
  	//window�滻Ϊdocument
	//$(document).click(function(e){if(e.target.nodeName == "HTML"){if(e.clientY < $(this).height()/2){up();}else{down();}}});
	$(".pre").click(function(){
				up();
				$(".next").css("display","block");		 
				if($('#book').scrollTop()!=0){
					$(".pre").css("display","block");
					}else{ $(".pre").css("display","none");}
					});
	$(".next").click(function(){

				down();
				$(".pre").css("display","block");
				if($('#book').scrollTop()==$('.table_height').height()-480){
				$(".next").css("display","none");
				}else{$(".next").css("display","block");}
				});
	$(document).keyup(function(e){if(e.keyCode == 40 || e.keyCode == 32|| e.keyCode == 39 ){down();$(".pre").css("display","block");
				if($('#book').scrollTop()==$('.table_height').height()-480){
				$(".next").css("display","none");
				}else{$(".next").css("display","block");}}else if(e.keyCode == 38|| e.keyCode == 37) {up();$(".next").css("display","block");		 
				if($('#book').scrollTop()!=0){
					$(".pre").css("display","block");
					}else{ $(".pre").css("display","none");}}});
	if(localStorage[window.location.href]){$('#book').animate({scrollTop:localStorage[window.location.href]}, 0);}
	
});

document.write(
  "<style>" +
  "* { margin: 0; padding: 0; }" +
  "body { background-color: #EBEBE4; }" +
  "#book {" +
  "  position: absolute;" +
  "  top: 50%;" +
  "  left: 50%;" +
  "  overflow: hidden;" +
  "  font-family: Georgia,serif;" +
  "  font-size: 20px;" +
  "  line-height: "+line_height+"px;" +
  "  width: 900px;" +
  "  height: "+scroll_step+"px;" +
  "  margin-top: -"+scroll_step/2+"px;" +
  "  margin-left: -450px;" +
  "}" +
  "#book p { margin-bottom: "+line_height+"px; padding: 0 5px; }" +
  "#book td.zh{ font-size:18px!important;}"+
  "</style>"
);