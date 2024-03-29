/// This section of code leverages <a hrfe="https://codemirror.net">CodeMirror</a>
/// Replicating respective codemirror license as follows:
/// <hr/>
/// MIT License
/// Copyright (C) 2017 by Marijn Haverbeke <marijnh@gmail.com> and others
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.
/// 
/// <hr/>
Class ompare.Report.SourceView Extends %CSP.Page
{

/// Event handler for <b>PAGE</b> event: this is invoked in order to  
/// generate the content of a csp page.
ClassMethod OnPage() As %Status [ ServerOnly = 1 ]
{
	set script=$G(%request.Data("Script",1))
	if script'="" {
		if script="ScriptDiffMatchPatch" {
			Do ##class(ompare.Report.SourceViewBase).ScriptDiffMatchPatch()
		} elseif script="ScriptLibCodemirror" {
			Do ##class(ompare.Report.SourceViewBase).ScriptLibCodemirror()
		} elseif script="ScriptModeXml" {
			Do ##class(ompare.Report.SourceViewBase).ScriptModeXml()	
		} elseif script="ScriptModeCSS" {
			Do ..ScriptModeCSS()
		} elseif script="ScriptModeJS" {
			Do ..ScriptModeJS()	
		} elseif script="ScriptModeHtmlMixed" {
			Do ..ScriptModeHtmlMixed()	
		}  elseif script="ScriptAddonMerge" {
			Do ##class(ompare.Report.SourceViewBase).ScriptAddonMerge()	
		} elseif script="ScriptModeMumps" {
			Do ..ScriptModeMumps()
		}
		Quit $$$OK
	}
	set css=$G(%request.Data("CSS",1))
	if css'="" {
		if css="AddonMerge" {
			Do ..CSSAddonMerge()
			Quit $$$OK
		} elseif css="LibCodeMirror" {
			Do ..CSSLibCodeMirror()
			Quit $$$OK
		}
		Quit $$$OK	
	}

	// Example:
	// http://172.24.0.122:57772/csp/traklab/ompare.Report.SourceView.cls?sfEnv=BASE&sfNS=INST-ABMMHO&sfT=C&sfTN=Instruments.Common.ASTM.XMLTCPService&sfST=M&sfSTN=OnProcessInput&stEnv=BASETEST&stNS=INST-ABMMHO&stT=C&stTN=Instruments.Common.ASTM.XMLTCPService&stST=M&stSTN=OnProcessInput
	W "<!doctype html>"
	W "<meta charset=""utf-8""/>"
	W !,"<html>"
	Do ..HTMLHead()
	
	Do ..HTMLBody()	
	W !,"</html>"
	Quit $$$OK
}

ClassMethod HTMLBody()
{
	
	W "<body>"
	&HTML<
	<div id='nav'></div>
	>
	
	set sfD=$G(%request.Data("sfD",1))
 	set sfEnv=$G(%request.Data("sfEnv",1))
 	set sfNS=$G(%request.Data("sfNS",1))
	set sfT=$G(%request.Data("sfT",1))
	set sfTN=$G(%request.Data("sfTN",1))
	set sfST=$G(%request.Data("sfST",1))
	set sfSTN=$G(%request.Data("sfSTN",1))
	set stD=$G(%request.Data("stD",1))
 	set stEnv=$G(%request.Data("stEnv",1))
 	set stNS=$G(%request.Data("stNS",1))
 	set stT=$G(%request.Data("stT",1))
 	set stTN=$G(%request.Data("stTN",1))
 	set stST=$G(%request.Data("stST",1))
 	set stSTN=$G(%request.Data("stSTN",1))
	
	/// Make human readable display names extensible for subclasses of ompare.ReportType.Base
	// set type=$CASE($Select(sfT'="":sfT,1:stT),"C":"Class","R":"Routine","LUT":"Lookup","SQL":"SQL Table","HL7":"HL7 Schema",:"")
	set typeCode=$Select(sfT'="":sfT,1:stT)
	&SQL(SELECT $PIECE(p."Name",'RPTType',2) into :type
		FROM %Dictionary.CompiledParameter p,%Dictionary.CompiledClass c
		WHERE p."Name" %STARTSWITH 'RPTType'
		AND p.parent=c.%ID
		AND c.Super='ompare.ReportType.Base'
		AND p._Default=:typeCode)
	set:'SQLCODE=0 type=""
	set typename=$S(sfTN'="":sfTN,1:stTN)
	//set subtype=$CASE($Select(sfST'="":sfST,1:stST),"M":"Method","MS":"Method Signature","PR":"Parameter","P":"Property","S":"Summary","L":"Line Label","X":"XData",:"")
	set subtypeCode=$Select(sfST'="":sfST,1:stST)
	&SQL(SELECT $PIECE(p."Name",'RPTSubType',2) into :subtype
		FROM %Dictionary.CompiledParameter p,%Dictionary.CompiledClass c
		WHERE p."Name" %STARTSWITH 'RPTSubType'
		AND p.parent=c.%ID
		AND c.Super='ompare.ReportType.Base'
		AND p._Default=:subtypeCode)
	set:'SQLCODE=0 subtype=""
	set subtypename=$S(sfSTN'="":sfSTN,1:stSTN)
	/*
	W !,"<table>"
	W !,"<tr><th>Key</th><th>Value</th></tr>"
	W !,"<tr><td>sfD</td><td>",sfD,"</td></tr>"
	W !,"<tr><td>sfEnv</td><td>",sfEnv,"</td></tr>"
	W !,"<tr><td>sfNS</td><td>",sfNS,"</td></tr>"
	W !,"<tr><td>sfT</td><td>",sfT,"</td></tr>"
	W !,"<tr><td>sfTN</td><td>",sfTN,"</td></tr>"
	W !,"<tr><td>sfST</td><td>",sfST,"</td></tr>"
	W !,"<tr><td>sfSTN</td><td>",sfSTN,"</td></tr>"
	W !,"<tr><td>stD</td><td>",stD,"</td></tr>"
	W !,"<tr><td>stEnv</td><td>",stEnv,"</td></tr>"
	W !,"<tr><td>stNS</td><td>",stNS,"</td></tr>"
	W !,"<tr><td>stT</td><td>",stT,"</td></tr>"
	W !,"<tr><td>stTN</td><td>",stTN,"</td></tr>"
	W !,"<tr><td>stST</td><td>",stST,"</td></tr>"
	W !,"<tr><td>stSTN</td><td>",stSTN,"</td></tr>"
	W !,"</table>"
	*/
	
	
	// Text Block identifier for "From" target
	//set fromSignature=$G(%request.Data("sfS",1))
	set fromSignature=""
	if sfEnv'="",sfNS'="",sfT'="",sfTN'="" {
		if sfST'="",sfSTN'="" {
			set fromSignature=$G(^ompare("Data",sfEnv,sfNS,sfT,sfTN,sfST,sfSTN))
			;W !,"<p>S1</p>"
		} else {
			set fromSignature=$G(^ompare("Data",sfEnv,sfNS,sfT,sfTN))
			;W !,"<p>S2</p>"
		}
	}
	// Text Block identifier for "To" target
	set toSignature=""
	if stEnv'="",stNS'="",stT'="",stTN'="" {
		if stST'="",stSTN'="" {
			if stD'="" {
				set toSignature=$G(^ompare("History",stD,stEnv,stNS,stT,stTN,stST,stSTN))
				;W !,"<p>T1</p>"
			} else {
				set toSignature=$G(^ompare("Data",stEnv,stNS,stT,stTN,stST,stSTN))
				;W !,"<p>T2</p>"
			}
		} else {
			if stD'="" {
				set toSignature=$G(^ompare("History",stD,stEnv,stNS,stT,stTN))
				;W !,"<p>T3</p>"
			} else {
				set toSignature=$G(^ompare("Data",stEnv,stNS,stT,stTN))
				//W !,"<p>stEnv:",stEnv,"</p>"
				//W !,"<p>stNS:",stNS,"</p>"
				//W/ !,"<p>stT:",stT,"</p>"
				//W !,"<p>stTN:",stTN,"</p>"
				//W !,"<P>toSig:",toSignature,"</p>"
			}
		}
	}
	
	//W !,"<p>From Sig:",fromSignature,"</p>"
	//W !,"<p>To Sig:",toSignature,"</p>"
	
	
	W !,"<article>"
	W !,"<h2>Compare Source ",type," <i>",typename,"</i>"
	W:subtype'="" " at ",subtype," <i>",subtypename,"</i>" // Empty in case of Lookup Table
	W "</h2>"
	W !,"<table style='width:100%'>"
	W !,"<tr>"
	W !,"<td align=""left"">From:<br/>&nbsp;&nbsp;Environment:",$ZCONVERT(sfEnv,"O","HTML"),"<br/>&nbsp;&nbsp;Namespace:",$ZCONVERT(sfNS,"O","HTML"),"</td>"
	W !,"<td align=""right"">To:<br/>Environment:",$ZCONVERT(stEnv,"O","HTML"),$S(stD'="":"("_$ZD(stD)_")",1:""),"&nbsp;&nbsp;<br/>Namespace:",$ZCONVERT(stNS,"O","HTML"),"&nbsp;&nbsp;</td>"
	W !,"</tr>"
	W !,"</table>"
	
	/*
	///W !,"<div>From: "
	//W !,"&nbsp;&nbsp;Environment:",$ZCONVERT(sfEnv,"O","HTML"),"<br/>"
	//W !,"&nbsp;&nbsp;Namespace:",$ZCONVERT(sfNS,"O","HTML"),"</div>"
	//W !,"<div>To:<br/>"
	//W !,"&nbsp;&nbsp;Environment:",$ZCONVERT(stEnv,"O","HTML"),"<br/>"
	//W !,"&nbsp;&nbsp;Namespace:",$ZCONVERT(stNS,"O","HTML"),"</div>"
	
	//W !,"For ",type," <em>",typename,"</em> at ",subtype," <em>",subtypename,"</em><br/>"
	*/
	
	W !,"<button onclick=""connect = connect ? null :'align'; initUI()"">Align</button>"
	W !,"<button onclick=""collapse = !collapse; initUI()"">Collapse</button>"
	W !,"<div id='view'></div>"
	
 
 //W !,"<script language=""JavaScript"">"
 //Do ##class(ompare.Report.SourceViewBase).ScriptLibCodemirror()
 //Do ##class(ompare.Report.SourceViewBase).ScriptModeXml()
 //Do ..ScriptModeCSS()
 //Do ..ScriptModeJS()
 //Do ..ScriptModeHtmlMixed()
 //Do ##class(ompare.Report.SourceViewBase).ScriptDiffMatchPatch()
 //Do ##class(ompare.Report.SourceViewBase).ScriptAddonMerge()
 //W !,"</script>"
 W !,"<script>"
 W !,"var value, orig1, orig2, dv, panes = 2, highlight = true, connect = null, collapse = false;"
 W !,"function initUI() {"
 W !,"  if (value == null) return;"
 W !,"  var target = document.getElementById(""view"");"
 W !,"  target.innerHTML = """";"
 W !,"  dv = CodeMirror.MergeView(target, {"
 W !,"    value: value,"
 W !,"    origLeft: panes == 3 ? orig1 : null,"
 W !,"    orig: orig2,"
 W !,"    lineNumbers: true,"
 if (subtype="XData") {
	W !,"    mode: ""text/xml"","
 } elseif ((subtype="Method")||(subtype="Line Label")) {
 	W !,"    mode: ""text/x-mumps"","
 	//W !,"    mode: ""MUMPS"","
 } else {
	W !,"    mode: ""text/text"","	 
 }
 W !,"    highlightDifferences: highlight,"
 W !,"    connect: connect,"
 W !,"    collapseIdentical: collapse"
 W !,"  });"
 W !,"}"
 W !,""
 W !,"function toggleDifferences() {"
 W !,"  dv.setShowDifferences(highlight = !highlight);"
 W !,"}"
 W !,""
 W !,"window.onload = function() {"
 // W !,"  value = 'Te\nst\nTest ABC\nTEST';"
 //W !,"  orig1 = 'Te\nst\nTest DEF\nTEST';"
 //W !,"  orig2 = 'Te\nst\nTest GHI\nTEST';"
 W !,"   value='';"
 W !,"   orig1='';"
 W !,"   orig2='';"
 
 
 // K ^||TO
 
 if fromSignature'="" {
	set line=""
	for {
		set data=""
		set line=$Order(^ompare("DataSrc",fromSignature,line),+1,data)
		quit:line=""
		write !,"  value+='",$ZCONVERT(data,"O","JS"),"\n';"
	} 
 } else {
	write !,"  value+='Source Content not found';"
 }
 
 if toSignature'="" {
	set line=""
	for {
		set data=""
		set line=$Order(^ompare("DataSrc",toSignature,line),+1,data)
		quit:line=""
		write !,"  orig2+='",$ZCONVERT(data,"O","JS"),"\n';"
	} 
 } else {
	write !,"  orig2+='Source Content not found';"
 }
 
 
 //Write !,"  value='test1';"
 //Write !,"  orig2='test2';"
 
 //W !,"  orig1 = ""<!doctype html>\n\n"" + value.replace(/\.\.\//g, ""codemirror/"").replace(""yellow"", ""orange"");"
 //W !,"  orig2 = value.replace(/\u003cscript/g, ""\u003cscript type=text/javascript "")"
 //W !,"    .replace(""white"", ""purple;\n      font: comic sans;\n      text-decoration: underline;\n      height: 15em"");"
 W !,"  initUI();"
 W !,"};"
 W !,""
 W !,"function mergeViewHeight(mergeView) {"
 W !,"  function editorHeight(editor) {"
 W !,"    if (!editor) return 0;"
 W !,"    return editor.getScrollInfo().height;"
 W !,"  }"
 W !,"  return Math.max(editorHeight(mergeView.leftOriginal()),"
 W !,"                  editorHeight(mergeView.editor()),"
 W !,"                  editorHeight(mergeView.rightOriginal()));"
 W !,"}"
 W !,""
 W !,"function resize(mergeView) {"
 W !,"  var height = mergeViewHeight(mergeView);"
 W !,"  for(;;) {"
 W !,"    if (mergeView.leftOriginal())"
 W !,"      mergeView.leftOriginal().setSize(null, height);"
 W !,"    mergeView.editor().setSize(null, height);"
 W !,"    if (mergeView.rightOriginal())"
 W !,"      mergeView.rightOriginal().setSize(null, height);"
 W !,""
 W !,"    var newHeight = mergeViewHeight(mergeView);"
 W !,"    if (newHeight >= height) break;"
 W !,"    else height = newHeight;"
 W !,"  }"
 W !,"  mergeView.wrap.style.height = height + ""px"";"
 W !,"}"
 W !,"</script>"
 W !,"</article>"
 
 // Need to echo back main info as well as comment
 set T=$S($L(sfT):sfT,1:stT)
 set TN=$S($L(sfTN):sfTN,1:stTN)
 set ST=$S($L(sfST):sfST,1:stST)
 set STN=$S($L(sfSTN):sfSTN,1:stSTN)
 if $L(sfEnv),$L(sfNS),$L(stEnv),$L(stNS),$L(T),$L(TN),$L(ST),$L(STN) {
 	W !,"<form method=""POST"">"
 	//for hdn="sfEnv","sfNS","sfT","sfTN","sfST","sfSTN","stD","stEnv","stNS","stT","stTN","stST","stSTN" {
	//	W !,"<input type=""hidden"" name=""",hdn,""" value=""",$ZCVT(@hdn,"O","HTML"),""">"
	//}
	W !,"<input type=""hidden"" name=""sfEnv"" value=""",$ZCVT(sfEnv,"O","HTML"),""">"
	W !,"<input type=""hidden"" name=""sfNS"" value=""",$ZCVT(sfNS,"O","HTML"),""">"
	W !,"<input type=""hidden"" name=""sfT"" value=""",$ZCVT(sfT,"O","HTML"),""">"
	W !,"<input type=""hidden"" name=""sfTN"" value=""",$ZCVT(sfTN,"O","HTML"),""">"
	W !,"<input type=""hidden"" name=""sfST"" value=""",$ZCVT(sfST,"O","HTML"),""">"
	W !,"<input type=""hidden"" name=""sfSTN"" value=""",$ZCVT(sfSTN,"O","HTML"),""">"
	W !,"<input type=""hidden"" name=""stD"" value=""",$ZCVT(stD,"O","HTML"),""">"
	W !,"<input type=""hidden"" name=""stEnv"" value=""",$ZCVT(stEnv,"O","HTML"),""">"
	W !,"<input type=""hidden"" name=""stNS"" value=""",$ZCVT(stNS,"O","HTML"),""">"
	W !,"<input type=""hidden"" name=""stT"" value=""",$ZCVT(stT,"O","HTML"),""">"
	W !,"<input type=""hidden"" name=""stTN"" value=""",$ZCVT(stTN,"O","HTML"),""">"
	W !,"<input type=""hidden"" name=""stST"" value=""",$ZCVT(stST,"O","HTML"),""">"
	W !,"<input type=""hidden"" name=""stSTN"" value=""",$ZCVT(stSTN,"O","HTML"),""">"
 	set comment=$G(%request.Data("comment",1))
 	// If this is a comment update
 	if $Data(%request.Data("comment",1)) {
	 	if comment="" {
			K ^ompare("DIFFCOMMENT",sfEnv,sfNS,stEnv,stNS,T,TN,ST,STN)
		} else {
			S ^ompare("DIFFCOMMENT",sfEnv,sfNS,stEnv,stNS,T,TN,ST,STN)=comment	
		}
 	} else {
	 	set comment=$G(^ompare("DIFFCOMMENT",sfEnv,sfNS,stEnv,stNS,T,TN,ST,STN))
 	}
 	W !,"<label>Comment</label>"
 	W !,"<textarea name=""comment"" cols=80 rows=10>",$ZCVT(comment,"O","HTML"),"</textarea>"
    W !,"<input type=""submit"" value='Save Comment'></input>"
 	W !,"</form>"
 }
 W "</body>"
}

ClassMethod HTMLHead()
{
 W !,"<head>"
 #dim %response as %CSP.Response
 #dim %request as %CSP.Request
 
 s csslinkprefix="http://"_%request.GetCgiEnv("SERVER_NAME")_":"_%request.GetCgiEnv("SERVER_PORT",80)_%request.URL_"?CSS="
 //S %response.TraceDump=1
 //if %request.
 //W !,"<link rel=stylesheet href=""http://codemirror.net/doc/docs.css"">"
 //W !,"<link rel=stylesheet href=""http://codemirror.net/lib/codemirror.css"">"
 //W !,"<link rel=stylesheet href=""http://codemirror.net/addon/merge/merge.css"">"
 //W !,"<script src=""http://codemirror.net/lib/codemirror.js""></script>"
 //W !,"<script src=""http://codemirror.net/mode/xml/xml.js""></script>"
 //W !,"<script src=""http://codemirror.net/mode/css/css.js""></script>"
 //W !,"<script src=""http://codemirror.net/mode/javascript/javascript.js""></script>"
 //W !,"<script src=""http://codemirror.net/mode/htmlmixed/htmlmixed.js""></script>"
 //W !,"<script src=""https://cdnjs.cloudflare.com/ajax/libs/diff_match_patch/20121119/diff_match_patch.js""></script>"
 //W !,"<script src=""http://codemirror.net/addon/merge/merge.js""></script>"
 
 W !,"<link rel=stylesheet href=""",csslinkprefix,"LibCodeMirror"">"
 W !,"<link rel=stylesheet href=""",csslinkprefix,"AddonMerge"">"
 W !,"<script src=""ompare.Report.SourceView.cls?Script=ScriptLibCodemirror""></script>"
 W !,"<script src=""ompare.Report.SourceView.cls?Script=ScriptModeXml""></script>"
 //W !,"<script src=""ompare.Report.SourceView.cls?Script=ScriptModeCSS""></script>"
 //W !,"<script src=""ompare.Report.SourceView.cls?Script=ScriptModeJS""></script>"
 W !,"<script src=""ompare.Report.SourceView.cls?Script=ScriptModeHtmlMixed""></script>"
 W !,"<script src=""ompare.Report.SourceView.cls?Script=ScriptModeMumps""></script>"
 W !,"<script src=""ompare.Report.SourceView.cls?Script=ScriptDiffMatchPatch""></script>"
 W !,"<script src=""ompare.Report.SourceView.cls?Script=ScriptAddonMerge""></script>"
 W !,"<style>"
 W !,"    .CodeMirror { line-height: 1.2; }"
 W !,"    @media screen and (min-width: 1300px) {"
 W !,"      article { max-width: 2000px; }"
 W !,"      #nav { border-right: 499px solid transparent; }"
 W !,"    }"
 W !,"    span.clicky {"
 W !,"      cursor: pointer;"
 W !,"      background: #d70;"
 W !,"      color: white;"
 W !,"      padding: 0 3px;"
 W !,"      border-radius: 3px;"
 W !,"    }"
 W !,"  </style>"
 W !,"</head>"
}

ClassMethod CSSDoc()
{
}

ClassMethod CSSLibCodeMirror()
{
 W !,"/* BASICS */",!
 W !,".CodeMirror {"
 W !,"  /* Set height, width, borders, and global font properties here */"
 W !,"  font-family: monospace;"
 W !,"  height: 300px;"
 W !,"  color: black;"
 W !,"}",!
 W !,"/* PADDING */",!
 W !,".CodeMirror-lines {"
 W !,"  padding: 4px 0; /* Vertical padding around content */"
 W !,"}"
 W !,".CodeMirror pre {"
 W !,"  padding: 0 4px; /* Horizontal padding of content */"
 W !,"}",!
 W !,".CodeMirror-scrollbar-filler, .CodeMirror-gutter-filler {"
 W !,"  background-color: white; /* The little square between H and V scrollbars */"
 W !,"}",!
 W !,"/* GUTTER */",!
 W !,".CodeMirror-gutters {"
 W !,"  border-right: 1px solid #ddd;"
 W !,"  background-color: #f7f7f7;"
 W !,"  white-space: nowrap;"
 W !,"}"
 W !,".CodeMirror-linenumbers {}"
 W !,".CodeMirror-linenumber {"
 W !,"  padding: 0 3px 0 5px;"
 W !,"  min-width: 20px;"
 W !,"  text-align: right;"
 W !,"  color: #999;"
 W !,"  white-space: nowrap;"
 W !,"}",!
 W !,".CodeMirror-guttermarker { color: black; }"
 W !,".CodeMirror-guttermarker-subtle { color: #999; }",!
 W !,"/* CURSOR */",!
 W !,".CodeMirror-cursor {"
 W !,"  border-left: 1px solid black;"
 W !,"  border-right: none;"
 W !,"  width: 0;"
 W !,"}"
 W !,"/* Shown when moving in bi-directional text */"
 W !,".CodeMirror div.CodeMirror-secondarycursor {"
 W !,"  border-left: 1px solid silver;"
 W !,"}"
 W !,".cm-fat-cursor .CodeMirror-cursor {"
 W !,"  width: auto;"
 W !,"  border: 0;"
 W !,"  background: #7e7;"
 W !,"}"
 W !,".cm-fat-cursor div.CodeMirror-cursors {"
 W !,"  z-index: 1;"
 W !,"}",!
 W !,".cm-animate-fat-cursor {"
 W !,"  width: auto;"
 W !,"  border: 0;"
 W !,"  -webkit-animation: blink 1.06s steps(1) infinite;"
 W !,"  -moz-animation: blink 1.06s steps(1) infinite;"
 W !,"  animation: blink 1.06s steps(1) infinite;"
 W !,"  background-color: #7e7;"
 W !,"}"
 W !,"@-moz-keyframes blink {"
 W !,"  0% {}"
 W !,"  50% { background-color: transparent; }"
 W !,"  100% {}"
 W !,"}"
 W !,"@-webkit-keyframes blink {"
 W !,"  0% {}"
 W !,"  50% { background-color: transparent; }"
 W !,"  100% {}"
 W !,"}"
 W !,"@keyframes blink {"
 W !,"  0% {}"
 W !,"  50% { background-color: transparent; }"
 W !,"  100% {}"
 W !,"}",!
 W !,"/* Can style cursor different in overwrite (non-insert) mode */"
 W !,".CodeMirror-overwrite .CodeMirror-cursor {}",!
 W !,".cm-tab { display: inline-block; text-decoration: inherit; }"

 W !,".CodeMirror-ruler {"
 W !,"  border-left: 1px solid #ccc;"
 W !,"  position: absolute;"
 W !,"}"

 W !,"/* DEFAULT THEME */"

 W !,".cm-s-default .cm-header {color: blue;}"
 W !,".cm-s-default .cm-quote {color: #090;}"
 W !,".cm-negative {color: #d44;}"
 W !,".cm-positive {color: #292;}"
 W !,".cm-header, .cm-strong {font-weight: bold;}"
 W !,".cm-em {font-style: italic;}"
 W !,".cm-link {text-decoration: underline;}"
 W !,".cm-strikethrough {text-decoration: line-through;}"

 W !,".cm-s-default .cm-keyword {color: #708;}"
 W !,".cm-s-default .cm-atom {color: #219;}"
 W !,".cm-s-default .cm-number {color: #164;}"
 W !,".cm-s-default .cm-def {color: #00f;}"
 W !,".cm-s-default .cm-variable,"
 W !,".cm-s-default .cm-punctuation,"
 W !,".cm-s-default .cm-property,"
 W !,".cm-s-default .cm-operator {}"
 W !,".cm-s-default .cm-variable-2 {color: #05a;}"
 W !,".cm-s-default .cm-variable-3 {color: #085;}"
 W !,".cm-s-default .cm-comment {color: #a50;}"
 W !,".cm-s-default .cm-string {color: #a11;}"
 W !,".cm-s-default .cm-string-2 {color: #f50;}"
 W !,".cm-s-default .cm-meta {color: #555;}"
 W !,".cm-s-default .cm-qualifier {color: #555;}"
 W !,".cm-s-default .cm-builtin {color: #30a;}"
 W !,".cm-s-default .cm-bracket {color: #997;}"
 W !,".cm-s-default .cm-tag {color: #170;}"
 W !,".cm-s-default .cm-attribute {color: #00c;}"
 W !,".cm-s-default .cm-hr {color: #999;}"
 W !,".cm-s-default .cm-link {color: #00c;}"

 W !,".cm-s-default .cm-error {color: #f00;}"
 W !,".cm-invalidchar {color: #f00;}"

 W !,".CodeMirror-composing { border-bottom: 2px solid; }"

 W !,"/* Default styles for common addons */"

 W !,"div.CodeMirror span.CodeMirror-matchingbracket {color: #0f0;}"
 W !,"div.CodeMirror span.CodeMirror-nonmatchingbracket {color: #f22;}"
 W !,".CodeMirror-matchingtag { background: rgba(255, 150, 0, .3); }"
 W !,".CodeMirror-activeline-background {background: #e8f2ff;}"

 W !,"/* STOP */"

 W !,"/* The rest of this file contains styles related to the mechanics of"
 W !,"   the editor. You probably shouldn't touch them. */"

 W !,".CodeMirror {"
 W !,"  position: relative;"
 W !,"  overflow: hidden;"
 W !,"  background: white;"
 W !,"}"

 W !,".CodeMirror-scroll {"
 W !,"  overflow: scroll !important; /* Things will break if this is overridden */"
 W !,"  /* 30px is the magic margin used to hide the element's real scrollbars */"
 W !,"  /* See overflow: hidden in .CodeMirror */"
 W !,"  margin-bottom: -30px; margin-right: -30px;"
 W !,"  padding-bottom: 30px;"
 W !,"  height: 100%;"
 W !,"  outline: none; /* Prevent dragging from highlighting the element */"
 W !,"  position: relative;"
 W !,"}"
 W !,".CodeMirror-sizer {"
 W !,"  position: relative;"
 W !,"  border-right: 30px solid transparent;"
 W !,"}"

 W !,"/* The fake, visible scrollbars. Used to force redraw during scrolling"
 W !,"   before actual scrolling happens, thus preventing shaking and"
 W !,"   flickering artifacts. */"
 W !,".CodeMirror-vscrollbar, .CodeMirror-hscrollbar, .CodeMirror-scrollbar-filler, .CodeMirror-gutter-filler {"
 W !,"  position: absolute;"
 W !,"  z-index: 6;"
 W !,"  display: none;"
 W !,"}"
 W !,".CodeMirror-vscrollbar {"
 W !,"  right: 0; top: 0;"
 W !,"  overflow-x: hidden;"
 W !,"  overflow-y: scroll;"
 W !,"}"
 W !,".CodeMirror-hscrollbar {"
 W !,"  bottom: 0; left: 0;"
 W !,"  overflow-y: hidden;"
 W !,"  overflow-x: scroll;"
 W !,"}"
 W !,".CodeMirror-scrollbar-filler {"
 W !,"  right: 0; bottom: 0;"
 W !,"}"
 W !,".CodeMirror-gutter-filler {"
 W !,"  left: 0; bottom: 0;"
 W !,"}"

 W !,".CodeMirror-gutters {"
 W !,"  position: absolute; left: 0; top: 0;"
 W !,"  min-height: 100%;"
 W !,"  z-index: 3;"
 W !,"}"
 W !,".CodeMirror-gutter {"
 W !,"  white-space: normal;"
 W !,"  height: 100%;"
 W !,"  display: inline-block;"
 W !,"  vertical-align: top;"
 W !,"  margin-bottom: -30px;"
 W !,"  /* Hack to make IE7 behave */"
 W !,"  *zoom:1;"
 W !,"  *display:inline;"
 W !,"}"
 W !,".CodeMirror-gutter-wrapper {"
 W !,"  position: absolute;"
 W !,"  z-index: 4;"
 W !,"  background: none !important;"
 W !,"  border: none !important;"
 W !,"}"
 W !,".CodeMirror-gutter-background {"
 W !,"  position: absolute;"
 W !,"  top: 0; bottom: 0;"
 W !,"  z-index: 4;"
 W !,"}"
 W !,".CodeMirror-gutter-elt {"
 W !,"  position: absolute;"
 W !,"  cursor: default;"
 W !,"  z-index: 4;"
 W !,"}"
 W !,".CodeMirror-gutter-wrapper {"
 W !,"  -webkit-user-select: none;"
 W !,"  -moz-user-select: none;"
 W !,"  user-select: none;"
 W !,"}"

 W !,".CodeMirror-lines {"
 W !,"  cursor: text;"
 W !,"  min-height: 1px; /* prevents collapsing before first draw */"
 W !,"}"
 W !,".CodeMirror pre {"
 W !,"  /* Reset some styles that the rest of the page might have set */"
 W !,"  -moz-border-radius: 0; -webkit-border-radius: 0; border-radius: 0;"
 W !,"  border-width: 0;"
 W !,"  background: transparent;"
 W !,"  font-family: inherit;"
 W !,"  font-size: inherit;"
 W !,"  margin: 0;"
 W !,"  white-space: pre;"
 W !,"  word-wrap: normal;"
 W !,"  line-height: inherit;"
 W !,"  color: inherit;"
 W !,"  z-index: 2;"
 W !,"  position: relative;"
 W !,"  overflow: visible;"
 W !,"  -webkit-tap-highlight-color: transparent;"
 W !,"  -webkit-font-variant-ligatures: none;"
 W !,"  font-variant-ligatures: none;"
 W !,"}"
 W !,".CodeMirror-wrap pre {"
 W !,"  word-wrap: break-word;"
 W !,"  white-space: pre-wrap;"
 W !,"  word-break: normal;"
 W !,"}"

 W !,".CodeMirror-linebackground {"
 W !,"  position: absolute;"
 W !,"  left: 0; right: 0; top: 0; bottom: 0;"
 W !,"  z-index: 0;"
 W !,"}"

 W !,".CodeMirror-linewidget {"
 W !,"  position: relative;"
 W !,"  z-index: 2;"
 W !,"  overflow: auto;"
 W !,"}"

 W !,".CodeMirror-widget {}"

 W !,".CodeMirror-code {"
 W !,"  outline: none;"
 W !,"}"

 W !,"/* Force content-box sizing for the elements where we expect it */"
 W !,".CodeMirror-scroll,"
 W !,".CodeMirror-sizer,"
 W !,".CodeMirror-gutter,"
 W !,".CodeMirror-gutters,"
 W !,".CodeMirror-linenumber {"
 W !,"  -moz-box-sizing: content-box;"
 W !,"  box-sizing: content-box;"
 W !,"}"

 W !,".CodeMirror-measure {"
 W !,"  position: absolute;"
 W !,"  width: 100%;"
 W !,"  height: 0;"
 W !,"  overflow: hidden;"
 W !,"  visibility: hidden;"
 W !,"}"

 W !,".CodeMirror-cursor { position: absolute; }"
 W !,".CodeMirror-measure pre { position: static; }"

 W !,"div.CodeMirror-cursors {"
 W !,"  visibility: hidden;"
 W !,"  position: relative;"
 W !,"  z-index: 3;"
 W !,"}"
 W !,"div.CodeMirror-dragcursors {"
 W !,"  visibility: visible;"
 W !,"}"

 W !,".CodeMirror-focused div.CodeMirror-cursors {"
 W !,"  visibility: visible;"
 W !,"}"

 W !,".CodeMirror-selected { background: #d9d9d9; }"
 W !,".CodeMirror-focused .CodeMirror-selected { background: #d7d4f0; }"
 W !,".CodeMirror-crosshair { cursor: crosshair; }"
 W !,".CodeMirror-line::selection, .CodeMirror-line > span::selection, .CodeMirror-line > span > span::selection { background: #d7d4f0; }"
 W !,".CodeMirror-line::-moz-selection, .CodeMirror-line > span::-moz-selection, .CodeMirror-line > span > span::-moz-selection { background: #d7d4f0; }"

 W !,".cm-searching {"
 W !,"  background: #ffa;"
 W !,"  background: rgba(255, 255, 0, .4);"
 W !,"}"

 W !,"/* IE7 hack to prevent it from returning funny offsetTops on the spans */"
 W !,".CodeMirror span { *vertical-align: text-bottom; }"

 W !,"/* Used to force a border model for a node */"
 W !,".cm-force-border { padding-right: .1px; }"

 W !,"@media print {"
 W !,"  /* Hide the cursor when printing */"
 W !,"  .CodeMirror div.CodeMirror-cursors {"
 W !,"    visibility: hidden;"
 W !,"  }"
 W !,"}"

 W !,"/* See issue #2901 */"
 W !,".cm-tab-wrap-hack:after { content: ''; }"

 W !,"/* Help users use markselection to safely style text background */"
 W !,"span.CodeMirror-selectedtext { background: none; }"
}

ClassMethod CSSAddonMerge()
{
 W !,".CodeMirror-merge {"
 W !,"  position: relative;"
 W !,"  border: 1px solid #ddd;"
 W !,"  white-space: pre;"
 W !,"}"

 W !,".CodeMirror-merge, .CodeMirror-merge .CodeMirror {"
 W !,"  height: 350px;"
 W !,"}"

 W !,".CodeMirror-merge-2pane .CodeMirror-merge-pane { width: 47%; }"
 W !,".CodeMirror-merge-2pane .CodeMirror-merge-gap { width: 6%; }"
 W !,".CodeMirror-merge-3pane .CodeMirror-merge-pane { width: 31%; }"
 W !,".CodeMirror-merge-3pane .CodeMirror-merge-gap { width: 3.5%; }"

 W !,".CodeMirror-merge-pane {"
 W !,"  display: inline-block;"
 W !,"  white-space: normal;"
 W !,"  vertical-align: top;"
 W !,"}"
 W !,".CodeMirror-merge-pane-rightmost {"
 W !,"  position: absolute;"
 W !,"  right: 0px;"
 W !,"  z-index: 1;"
 W !,"}"

 W !,".CodeMirror-merge-gap {"
 W !,"  z-index: 2;"
 W !,"  display: inline-block;"
 W !,"  height: 100%;"
 W !,"  -moz-box-sizing: border-box;"
 W !,"  box-sizing: border-box;"
 W !,"  overflow: hidden;"
 W !,"  border-left: 1px solid #ddd;"
 W !,"  border-right: 1px solid #ddd;"
 W !,"  position: relative;"
 W !,"  background: #f8f8f8;"
 W !,"}"

 W !,".CodeMirror-merge-scrolllock-wrap {"
 W !,"  position: absolute;"
 W !,"  bottom: 0; left: 50%;"
 W !,"}"
 W !,".CodeMirror-merge-scrolllock {"
 W !,"  position: relative;"
 W !,"  left: -50%;"
 W !,"  cursor: pointer;"
 W !,"  color: #555;"
 W !,"  line-height: 1;"
 W !,"}"

 W !,".CodeMirror-merge-copybuttons-left, .CodeMirror-merge-copybuttons-right {"
 W !,"  position: absolute;"
 W !,"  left: 0; top: 0;"
 W !,"  right: 0; bottom: 0;"
 W !,"  line-height: 1;"
 W !,"}"

 W !,".CodeMirror-merge-copy {"
 W !,"  position: absolute;"
 W !,"  cursor: pointer;"
 W !,"  color: #44c;"
 W !,"  z-index: 3;"
 W !,"}"

 W !,".CodeMirror-merge-copy-reverse {"
 W !,"  position: absolute;"
 W !,"  cursor: pointer;"
 W !,"  color: #44c;"
 W !,"}"

 W !,".CodeMirror-merge-copybuttons-left .CodeMirror-merge-copy { left: 2px; }"
 W !,".CodeMirror-merge-copybuttons-right .CodeMirror-merge-copy { right: 2px; }"

 W !,".CodeMirror-merge-r-inserted, .CodeMirror-merge-l-inserted {"
 W !,"  background-image: url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAMAAAACCAYAAACddGYaAAAAGUlEQVQI12MwuCXy3+CWyH8GBgYGJgYkAABZbAQ9ELXurwAAAABJRU5ErkJggg==);"
 W !,"  background-position: bottom left;"
 W !,"  background-repeat: repeat-x;"
 W !,"}",!
 W !,".CodeMirror-merge-r-deleted, .CodeMirror-merge-l-deleted {"
 W !,"  background-image: url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAMAAAACCAYAAACddGYaAAAAGUlEQVQI12M4Kyb2/6yY2H8GBgYGJgYkAABURgPz6Ks7wQAAAABJRU5ErkJggg==);"
 W !,"  background-position: bottom left;"
 W !,"  background-repeat: repeat-x;"
 W !,"}",!
 W !,".CodeMirror-merge-r-chunk { background: #ffffe0; }"
 W !,".CodeMirror-merge-r-chunk-start { border-top: 1px solid #ee8; }"
 W !,".CodeMirror-merge-r-chunk-end { border-bottom: 1px solid #ee8; }"
 W !,".CodeMirror-merge-r-connect { fill: #ffffe0; stroke: #ee8; stroke-width: 1px; }",!
 W !,".CodeMirror-merge-l-chunk { background: #eef; }"
 W !,".CodeMirror-merge-l-chunk-start { border-top: 1px solid #88e; }"
 W !,".CodeMirror-merge-l-chunk-end { border-bottom: 1px solid #88e; }"
 W !,".CodeMirror-merge-l-connect { fill: #eef; stroke: #88e; stroke-width: 1px; }",!
 W !,".CodeMirror-merge-l-chunk.CodeMirror-merge-r-chunk { background: #dfd; }"
 W !,".CodeMirror-merge-l-chunk-start.CodeMirror-merge-r-chunk-start { border-top: 1px solid #4e4; }"
 W !,".CodeMirror-merge-l-chunk-end.CodeMirror-merge-r-chunk-end { border-bottom: 1px solid #4e4; }",!
 W !,".CodeMirror-merge-collapsed-widget:before {"
 W !,"  content: ""(...)"";"
 W !,"}"
 W !,".CodeMirror-merge-collapsed-widget {"
 W !,"  cursor: pointer;"
 W !,"  color: #88b;"
 W !,"  background: #eef;"
 W !,"  border: 1px solid #ddf;"
 W !,"  font-size: 90%;"
 W !,"  padding: 0 3px;"
 W !,"  border-radius: 4px;"
 W !,"}"
 W !,".CodeMirror-merge-collapsed-line .CodeMirror-gutter-elt { display: none; }",!
}

ClassMethod ScriptModeCSS()
{
}

ClassMethod ScriptModeJS()
{
}

ClassMethod ScriptModeMumps()
{
  W !,"// CodeMirror, copyright (c) by Marijn Haverbeke and others"
 W !,"// Distributed under an MIT license: http://codemirror.net/LICENSE"
 W !,""
 W !,"/*"
 W !,"  This MUMPS Language script was constructed using vbscript.js as a template."
 W !,"*/"
 W !,""
 W !,"(function(mod) {"
 W !,"  if (typeof exports == ""object"" && typeof module == ""object"") // CommonJS"
 W !,"    mod(require(""../../lib/codemirror""));"
 W !,"  else if (typeof define == ""function"" && define.amd) // AMD"
 W !,"    define([""../../lib/codemirror""], mod);"
 W !,"  else // Plain browser env"
 W !,"    mod(CodeMirror);"
 W !,"})(function(CodeMirror) {"
 W !,"  ""use strict"";"
 W !,""
 W !,"  CodeMirror.defineMode(""mumps"", function() {"
 W !,"    function wordRegexp(words) {"
 W !,"      return new RegExp(""^(("" + words.join("")|("") + ""))\\b"", ""i"");"
 W !,"    }"
 W !,""
 W !,"    var singleOperators = new RegExp(""^[\\+\\-\\*/&#!_?\\\\<>=\\'\\[\\]]"");"
 W !,"    var doubleOperators = new RegExp(""^(('=)|(<=)|(>=)|('>)|('<)|([[)|(]])|(^$))"");"
 W !,"    var singleDelimiters = new RegExp(""^[\\.,:]"");"
 W !,"    var brackets = new RegExp(""[()]"");"
 W !,"    var identifiers = new RegExp(""^[%A-Za-z][A-Za-z0-9]*"");"
 W !,"    var commandKeywords = [""break"",""close"",""do"",""else"",""for"",""goto"", ""halt"", ""hang"", ""if"", ""job"",""kill"",""lock"",""merge"",""new"",""open"", ""quit"", ""read"", ""set"", ""tcommit"", ""trollback"", ""tstart"", ""use"", ""view"", ""write"", ""xecute"", ""b"",""c"",""d"",""e"",""f"",""g"", ""h"", ""i"", ""j"",""k"",""l"",""m"",""n"",""o"", ""q"", ""r"", ""s"", ""tc"", ""tro"", ""ts"", ""u"", ""v"", ""w"", ""x""];"
 W !,"    // The following list includes instrinsic functions _and_ special variables"
 W !,"    var intrinsicFuncsWords = [""\\$ascii"", ""\\$char"", ""\\$data"", ""\\$ecode"", ""\\$estack"", ""\\$etrap"", ""\\$extract"", ""\\$find"", ""\\$fnumber"", ""\\$get"", ""\\$horolog"", ""\\$io"", ""\\$increment"", ""\\$job"", ""\\$justify"", ""\\$length"", ""\\$name"", ""\\$next"", ""\\$order"", ""\\$piece"", ""\\$qlength"", ""\\$qsubscript"", ""\\$query"", ""\\$quit"", ""\\$random"", ""\\$reverse"", ""\\$select"", ""\\$stack"", ""\\$test"", ""\\$text"", ""\\$translate"", ""\\$view"", ""\\$x"", ""\\$y"", ""\\$a"", ""\\$c"", ""\\$d"", ""\\$e"", ""\\$ec"", ""\\$es"", ""\\$et"", ""\\$f"", ""\\$fn"", ""\\$g"", ""\\$h"", ""\\$i"", ""\\$j"", ""\\$l"", ""\\$n"", ""\\$na"", ""\\$o"", ""\\$p"", ""\\$q"", ""\\$ql"", ""\\$qs"", ""\\$r"", ""\\$re"", ""\\$s"", ""\\$st"", ""\\$t"", ""\\$tr"", ""\\$v"", ""\\$z""];"
 W !,"    var intrinsicFuncs = wordRegexp(intrinsicFuncsWords);"
 W !,"    var command = wordRegexp(commandKeywords);"
 W !,""
 W !,"    function tokenBase(stream, state) {"
 W !,"      if (stream.sol()) {"
 W !,"        state.label = true;"
 W !,"        state.commandMode = 0;"
 W !,"      }"
 W !,""
 W !,"      // The <space> character has meaning in MUMPS. Ignoring consecutive"
 W !,"      // spaces would interfere with interpreting whether the next non-space"
 W !,"      // character belongs to the command or argument context."
 W !,""
 W !,"      // Examine each character and update a mode variable whose interpretation is:"
 W !,"      //   >0 => command    0 => argument    <0 => command post-conditional"
 W !,"      var ch = stream.peek();"
 W !,""
 W !,"      if (ch == "" "" || ch == ""\t"") { // Pre-process <space>"
 W !,"        state.label = false;"
 W !,"        if (state.commandMode == 0)"
 W !,"          state.commandMode = 1;"
 W !,"        else if ((state.commandMode < 0) || (state.commandMode == 2))"
 W !,"          state.commandMode = 0;"
 W !,"      } else if ((ch != ""."") && (state.commandMode > 0)) {"
 W !,"        if (ch == "":"")"
 W !,"          state.commandMode = -1;   // SIS - Command post-conditional"
 W !,"        else"
 W !,"          state.commandMode = 2;"
 W !,"      }"
 W !,""
 W !,"      // Do not color parameter list as line tag"
 W !,"      if ((ch === ""("") || (ch === ""\u0009""))"
 W !,"        state.label = false;"
 W !,""
 W !,"      // MUMPS comment starts with "";"""
 W !,"      if (ch === "";"") {"
 W !,"        stream.skipToEnd();"
 W !,"        return ""comment"";"
 W !,"      }"
 W !,""
 W !,"      // Number Literals // SIS/RLM - MUMPS permits canonic number followed by concatenate operator"
 W !,"      if (stream.match(/^[-+]?\d+(\.\d+)?([eE][-+]?\d+)?/))"
 W !,"        return ""number"";"
 W !,""
 W !,"      // Handle Strings"
 W !,"      if (ch == '""') {"
 W !,"        if (stream.skipTo('""')) {"
 W !,"          stream.next();"
 W !,"          return ""string"";"
 W !,"        } else {"
 W !,"          stream.skipToEnd();"
 W !,"          return ""error"";"
 W !,"        }"
 W !,"      }"
 W !,""
 W !,"      // Handle operators and Delimiters"
 W !,"      if (stream.match(doubleOperators) || stream.match(singleOperators))"
 W !,"        return ""operator"";"
 W !,""
 W !,"      // Prevents leading ""."" in DO block from falling through to error"
 W !,"      if (stream.match(singleDelimiters))"
 W !,"        return null;"
 W !,""
 W !,"      if (brackets.test(ch)) {"
 W !,"        stream.next();"
 W !,"        return ""bracket"";"
 W !,"      }"
 W !,""
 W !,"      if (state.commandMode > 0 && stream.match(command))"
 W !,"        return ""variable-2"";"
 W !,""
 W !,"      if (stream.match(intrinsicFuncs))"
 W !,"        return ""builtin"";"
 W !,""
 W !,"      if (stream.match(identifiers))"
 W !,"        return ""variable"";"
 W !,""
 W !,"      // Detect dollar-sign when not a documented intrinsic function"
 W !,"      // ""^"" may introduce a GVN or SSVN - Color same as function"
 W !,"      if (ch === ""$"" || ch === ""^"") {"
 W !,"        stream.next();"
 W !,"        return ""builtin"";"
 W !,"      }"
 W !,""
 W !,"      // MUMPS Indirection"
 W !,"      if (ch === ""@"") {"
 W !,"        stream.next();"
 W !,"        return ""string-2"";"
 W !,"      }"
 W !,""
 W !,"      if (/[\w%]/.test(ch)) {"
 W !,"        stream.eatWhile(/[\w%]/);"
 W !,"        return ""variable"";"
 W !,"      }"
 W !,""
 W !,"      // Handle non-detected items"
 W !,"      stream.next();"
 W !,"      return ""error"";"
 W !,"    }"
 W !,""
 W !,"    return {"
 W !,"      startState: function() {"
 W !,"        return {"
 W !,"          label: false,"
 W !,"          commandMode: 0"
 W !,"        };"
 W !,"      },"
 W !,""
 W !,"      token: function(stream, state) {"
 W !,"        var style = tokenBase(stream, state);"
 W !,"        if (state.label) return ""tag"";"
 W !,"        return style;"
 W !,"      }"
 W !,"    };"
 W !,"  });"
 W !,""
 W !,"  CodeMirror.defineMIME(""text/x-mumps"", ""mumps"");"
 W !,"});"
 W !,""
}

ClassMethod ScriptModeHtmlMixed()
{
}

/// Event handler for <b>PreHTTP</b> event: this is invoked before
/// the HTTP headers for a CSP page have been sent.  All changes to the
/// <class>%CSP.Response</class> class, such as adding cookies, HTTP headers,
/// setting the content type etc. must be made from within the OnPreHTTP() method.
/// Also changes to the state of the CSP application such as changing
/// %session.EndSession or %session.AppTimeout must be made within the OnPreHTTP() method.
/// It is prefered that changes to %session.Preserve are also made in the OnPreHTTP() method
/// as this is more efficient, although it is supported in any section of the page.
/// Return <b>0</b> to prevent <method>OnPage</method> from being called.
ClassMethod OnPreHTTP() As %Boolean [ ServerOnly = 1 ]
{
	#dim %response as %CSP.Response
	set script=$G(%request.Data("Script",1))
	if script'="" {
		set %response.ContentType="application/x-javascript"	
	}
	set css=$G(%request.Data("CSS",1))
	if css'="" {
		set %response.ContentType="text/css"
	}
	Quit $$$OK
}

/// Location and Revision of this file in Perforce (Auto-updating)
Parameter SrcVer = "$Id$";

}

