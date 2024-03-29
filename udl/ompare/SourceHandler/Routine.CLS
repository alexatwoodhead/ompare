/// <pre>
/// Copyright (c) Alex Woodhead 2020
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
/// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
/// 
/// License MIT
/// Source: https://github.com/alexatwoodhead/ompare
/// Version: 1.0
/// </pre>
/// <p>
/// Source indexer for Mac routines<br/>
/// Extracts:
/// <ol><li>Implemention signatures for highlevel diffs</li>
/// <li><em>Optionally</em> functional source code lines for full-diff reporting</li>
/// <li>Creates an summary signature of Routine independent of the order in which line labels are defined</li>
/// </ol>
/// Source line leading and trailing whitespace is normalised.<br/>
/// <h3>Configuration</h3>
/// To exclude source code from being captured for detailed reports use schedule configuration option IncludeSourceCode=0<br/>
/// To control which routines are included in each target namespace for analysis 
/// update the lookup global using Interoperability LookupTables in SMP or directly.
/// When first run in each namespace the following defaults will be established:
/// <example>
/// ^ompare("Config","Exclude","%*.mac")=1
/// ^ompare("Config","Exclude","Ens*.mac")=1
/// ^ompare("Config","Exclude","RuleCache.*.mac")=1
/// ^ompare("Config","Exclude","SQLExport*.mac")=1
/// ^ompare("Config","Exclude","GCOM*.mac")=1
/// ^ompare("Config","Exclude","CacheSql*.mac")=1
/// </example>
/// Where value "1" means exclude and "0" means include.<br/>
/// Exclusions can layer for example to exclude all routines with prefix "ompare"
/// except do include analysis of any routines with prefix "ompareUtil":
/// <example>
/// ^ompare("Config","Exclude","ompare*.mac")=1
/// ^ompare("Config","Exclude","ompareUtil*.mac")=0
/// </example>
/// <h3>Treatment of comments</h3>
/// Analysis excludes single line comments "//" and ";"<br/>
/// Single line Text comments (";;") are retained for functional difference.
/// Excludes multiline comments. This is especially useful where whole line-labels
/// have been commented out and no longer participate in functional code
/// Multiline comments expect to start line with "/*" sequence
/// Multiline comments expect to terminate line with "*/".
/// <example>
/// TestRoutine
///  //Single comment line discarded
///  /* 
///   comment line multi 1 discarded
///   comment line multi 2 discarded
///   comment line multi 3 discarded
///   */
///  ; comment simple A discarded
///  ;; Text comment Retained
///  quit
///  /*
/// DiscardLable(y) discarded
///   Quit y+y discarded
///  */
/// Retain(z)
///   Quit z+z
/// </example>
/// Would be treated as:
/// <example>
/// TestRoutine
///  ;; Text comment Retained
///  quit
/// Retain(z)
///   Quit z+z
/// </example>
/// <h3>Legacy dot syntax</h3>
/// Legacy implementation is normalised for spacing as this does not cause funtional
/// difference.<br/>
/// <example>
/// Legacy
/// [tab][tab]set x=1[space]
/// [tab]d[space]
/// [space].[space]s x=2
/// [tab].d[space]
/// [tab].[space].s x=3
/// [space].[space]. (Will be discarded)
/// [tab].[space].[space]s x=4
/// [space]Q
/// </example>
/// Would be treated as implemented as:
/// <example>
/// Legacy
/// [space]set x=1
/// [space]d
/// [space].s x=2
/// [space].d
/// [space]..s x=3
/// [space]..s x=4
/// [space]Q
/// </example>
/// Note empty legacy sequence "[space].[space]." is not carried forward for analysis.<br/>
/// <h3>Source Control tokens</h3>
/// Source Control tokens can be suppressed via the Schedule properties:
/// <ul><li>SrcVersionTokenStart</li>
/// <li>SrcVersionTokenEnd (Optional)</li></ul>
/// For source control employing both start and end tokens: 
/// <example>
///  quit "TokenStart /path/to/project/TEST/routinename#23 TokenEnd"
/// </example>
/// is replaced with:
/// <example>
///  quit "TokenStart TokenEnd"
/// </example>
/// Or for systems that use a single start token and monpolise the rest of the source line
/// <example>
/// " ;;TokenStart /path/to/project/TEST/routinename#23"
/// </example>
/// is replaced with:
/// <example>
/// " ;;TokenStart"
/// </example>
/// Signatures are built up for individual line label segments.
/// A summary signature for routine is also constructed that is independent of 
/// original line label sequence
/// </p>
Class ompare.SourceHandler.Routine Extends ompare.SourceHandler.Base
{

/// Ensure this Code doesn't collide with other sub-class implementations of Base
/// Eg: "CLS" abbreviation for class
Parameter DocumentType As %String = "rou";

/// Main entry point for Routine Source Handler
ClassMethod IndexNamespace(namespace = "", logging = 0, includeSource = 0, schedule As ompare.Schedule = {$$$NULLOREF}) As %Status
{
	#define RPTType "R"
	#define RPTSubTypeLineLabel "L"
	#define RPTSubTypeConfig "CFG"
	#define RPTItemConfigMapped "IsMapped"
	#define RPTItemConfigSourceControlled "IsSourceControlled"
	#define RPTItemConfigSourceVersion "SrcVer"
	
	if '$IsObject(schedule) {
		set schedule=##class(ompare.Schedule).%New()
	}
	// Testing
    // Do ##class(ompare.SourceHandler.RoutineDefinition).IndexNamespace("USER",0,0)
	
	/*****************************
	 Start Template
	******************************/
	#dim tmpStream as %Stream.TmpCharacter
	Set tmpStream=##class(%Stream.TmpCharacter).%New()
	// It is necessary to switch namespace context within the method call as source code may not be 
	// deployed to target namespace
	set ret=$$$OK
	
	Quit:namespace="" $$$ERROR(5001,"Namespace not supplied to Routine Source Handler")
	
	New $NAMESPACE  // Ensures when method exits process will be returned to the original namespace
	
	try {	
		 // Generates <NAMESPACE> error if namespace doesn't exist
		 // Generate <PROTECT> error if user does not have access privilage
		set $NAMESPACE=namespace
	} catch errobj {
		// Name
		// Code
		// Location
		// Data
		if errobj.Name="<NAMESPACE>" {
			set ret=$$$ERROR(5001,"Cannot index namespace "_namespace_". Namespace does not exist.")
		} elseif errobj.Name="" {
			set ret=$$$ERROR(50001,"Cannot index namesapce "_namespace_". User "_$USERNAME_" does not have permission.")
		} else {
			set ret=$$$ERROR(5001,"Unknow error "_errobj.Name_". In code "_errobj.Code_" at location "_errobj.Location)
		}
	}
	Quit:$$$ISERR(ret) ret
    
	
	// Invoke sub-class extension code
	try {
		Do IndexerMain
	} catch ex {
		// Always report issue in output
		Do Log("Error","In SourceHandler.RoutineDefinition")
		Do Log("  Name:",ex.Name)
		Do Log("  Code:",ex.Code)
		Do Log("  Location:",ex.Location)
		Do Log("  Data:",ex.Data)
		Set ret=ex.AsStatus()
	}
	Quit ret
SetIsMapped(typeName="")
	quit:$$$RPTType=""
	quit:typeName=""
	quit:'##class(%Dictionary.CompiledMethod).%ExistsId("%Studio.SourceControl.ISC||IsMapped")
	// Assumes if the source control file is present on the filesystem then it is being source controlled
	// Requires both 3rd and 4th key to reuse generic export / import mechanism
	set ^||Data($$$RPTType,typeName,$$$RPTSubTypeConfig,$$$RPTItemConfigMapped)=##class(%Studio.SourceControl.ISC).IsMapped(typeName_".MAC")
	quit
SetIsSourceControlled(typeName="")
	quit:$$$RPTType=""
	quit:typeName=""
	quit:$Data(^Sources)<11
	quit:$$SourceControlClass^%occLibrary($Namespace)'="%Studio.SourceControl.ISC"
	// Assumes if the source control file is present on the filesystem then it is being source controlled
	// Requires both 3rd and 4th key to reuse generic export / import mechanism
	set ^||Data($$$RPTType,typeName,$$$RPTSubTypeConfig,$$$RPTItemConfigSourceControlled)=##class(%File).Exists(##class(%Studio.SourceControl.ISC).ExtName(typeName_".MAC"))
	quit
SetSourceVersion(typeName,data)
	quit:$$$RPTType=""
	quit:typeName=""
	set data=$ZSTRIP(data,"<>W")
	set:$E(data,1)=":" data=$ZSTRIP($E(data,2,*),"<>W")
	quit:data=""
	// Requires both 3rd and 4th key to reuse generic export / import mechanism
	set ^||Data($$$RPTType,typeName,$$$RPTSubTypeConfig,$$$RPTItemConfigSourceVersion)=data
	quit
SetSignature(typeName="", signature="",subTypeCode="", subTypeName="")
	Quit:$$$RPTType=""
	Quit:typeName=""
	Quit:signature=""
	if subTypeCode'="",subTypeName'="" {
		set ^||Data($$$RPTType,typeName,subTypeCode,subTypeName)=signature
	} else {
		set ^||Data($$$RPTType,typeName)=signature
	}
	quit
	// To itterate on the names and signatures of a particular subType
	// pass typeName by value required
	// pass signature by reference
	// pass subTypeCode by value required
	// pass subTypeName by reference required
NextSignature(typeName,signature,subTypeCode, subTypeName)
  set signature=""
  // subTypeName may be empty string at start of itteration
  Quit:typeName="" 0
  Quit:subTypeCode="" 0
  set subTypeName=$Order(^||Data($$$RPTType,typeName,subTypeCode,subTypeName),+1,signature)
  Quit:subTypeName="" 0 
  Quit 1
  // Write to stream AND conditionally to DataSrc
WriteLine(stream,data)
  // Intercept Source Control Tokens
  // eg: $I + d: //some/org/project/product/BASE/rtn/PRTDR9ORG.rtn#1 $
  // Converts to $I + d$
  set dataNoTokenVersion=""
  if schedule.SrcVersionTokenStart'="" {
	if schedule.SrcVersionTokenEnd'="" {
		set pattern=".E1"""_schedule.SrcVersionTokenStart_"""1.E1"""_schedule.SrcVersionTokenEnd_""""
  		for {
		  quit:data'?@pattern
		  s dataNoTokenVersion=dataNoTokenVersion_$P(data,schedule.SrcVersionTokenStart)_schedule.SrcVersionTokenStart_schedule.SrcVersionTokenEnd
		  set data=$P($P(data,schedule.SrcVersionTokenStart,2,999999),schedule.SrcVersionTokenEnd,2,999999)
	  	}
	} elseif data[schedule.SrcVersionTokenStart {
		// The source control token effectively matches to the end of the line
		set data=$P(data,schedule.SrcVersionTokenStart)	
	}
  }
  // Include remainder of line after token end if token version content removed
  set:$L(dataNoTokenVersion)>0 data=dataNoTokenVersion_data
  
  
  // strip any terminating whitespace from line
  set data=$ZSTRIP(data,">W")
  // reformatting lines
  // convert leading whitespace (Space / tab)
  // strip space between formatting dots "."
  // [Tab][Tab].[space].[space].[space]if x=123
  // becomes
  // [space]...if x=123
  set writeLineCounter=0
  set writeLineData=""
  set writeLineAtCommand=0
  set writeLineLength=$L(data)
  for writeLineCounter=1:1:writeLineLength {
	  quit:writeLineAtCommand
	  set writeLineChar=$E(data,writeLineCounter)
	  set writeLineChar=$ZSTRIP(writeLineChar,"*W")
	  if writeLineChar="" {
		 set:writeLineCounter=1 writeLineData=" " // Add single space to beginning of the line
	  }
	  // else will be ignoring additional whitespace prefix or interleaving dot white space
	  continue:writeLineChar=""
	  set writeLineData=writeLineData_writeLineChar  // append dot or other command character
	  set:writeLineChar'="." writeLineAtCommand=1
	  quit:writeLineChar'="."  // prevent loop incrementing writeLineCounter
  }
  // append the end of the line
  set:writeLineCounter<=writeLineLength writeLineData=writeLineData_$E(data,writeLineCounter+1,*)
  
  // Ignore Empty Lines
  Quit:writeLineData=""
  
  // Ignore non-function empty dot indented lines
  Quit:writeLineData?1" "."."
  
  // Junk comment lines with optional dots?
  Quit:writeLineData?1" "."."1(1";",2"/").E
  
  // TODO support multi-line comments. /*  comment */ style

  Do tmpStream.WriteLine(writeLineData)
  Do:includeSource AddLine($I(line),writeLineData)
  Quit
AddLine(line,data)
  Quit:+line=0
  // remove previous data
  if line=1 {
	 kill ^||DataSrcTmp
	 set ^||DataSrcTmp=+$H
  }
  set ^||DataSrcTmp(line)=data
  Quit
SaveLines(sig="")
  quit:sig=""
  if $Data(^||DataSrc(sig)) {
	// if the source record already exists simply update the last referenced date to today
	set ^||DataSrc(sig)=+$H
  } else {
	merge ^||DataSrc(sig)=^||DataSrcTmp
	Kill ^||DataSrcTmp
  }
  Quit 1
Log(label, value="")
	W !,label,":",value
	Quit
IsExcluded(name,reason)
	Quit:name="" 1
	// Change the type extension to uppercase 
	set extension=$ZCVT($P(name,".",$L(name,".")),"L")
	set name=$e(name,1,*-($L(extension)+1))
	// Check Exact match for exlcusion
	if +$G(^ompare("Config","Exclude",name_"."_extension)) {
		set reason=name_"."_extension
		quit 1	
	} elseif $Data(^ompare("Config","Exclude",name_"."_extension)) {
		// Explicitly NOT excluded
		quit 0	
	}
	// now recursively look to exclude by wildcard match.
	set found=0
	set reason=""
	set prefix=$e(name,1,*-1)_"*"
	for {
		set found=+$G(^ompare("Config","Exclude",prefix_"."_extension))
		set:found reason=prefix_"."_extension
		quit:found
		if $Data(^ompare("Config","Exclude",prefix_"."_extension)) {
			// Explicitly NOT excluded
			quit	
		}
		set prefix=$E(prefix,1,*-2)_"*"
		q:prefix="*"
	}
	quit found
	
IndexerMain
	/*****************************
	 End Template
	 Add sub-class code and supporting line labels from this point forward.
	******************************/
	// Default exclusions in this namespace
	// Start set once in first run namespace
	set hasConfig=0
	set testExclude=""
	for {
		set testExclude=$O(^ompare("Config","Exclude",testExclude))
		quit:testExclude=""
		if $E(testExclude,*-3,*)=".mac" {
			set hasConfig=1
			quit  // exit on first encountered
		}
	}
	if 'hasConfig {
		// ignore system routines
		set ^ompare("Config","Exclude","%*.mac")=1
		// ignore HealthShare routines
		set ^ompare("Config","Exclude","HS.*.mac")=1
		// ignore Ensemble support routines
		set ^ompare("Config","Exclude","Ens*.mac")=1
		// Ignore Ensemble Generated for Routing Rules
		set ^ompare("Config","Exclude","RuleCache.*.mac")=1
		// Ignore generated
		set ^ompare("Config","Exclude","SQLExport*.mac")=1
		// Routines from TrakCare Generated Layouts
		set ^ompare("Config","Exclude","GCOM*.mac")=1
		// Routines from Dynamic SQL statements
		set ^ompare("Config","Exclude","CacheSql*.mac")=1
	}
	// End set once in first run namespace

	set routinename=""
	for {
		set routinename=$Order(^rMAC(routinename))
		quit:routinename=""
		
		if (routinename?1.E1".G"1.N) {
			// Ends in *.G + numeric. Supports SQL projection
			Do:logging Log("Ignoring """_routinename_""" ends with",".G + numeric")
			continue
		}
		if $$IsExcluded(routinename_".mac",.reason) {
			Do:logging Log("Ignore """_routinename_""" matches filter",reason)
			continue	
		}		
		// Simple - Reindex ALL routines on demand
		Do:logging Log("ProcessRoutine",routinename_$C(13,10))
		
		Do IndexRoutine(routinename,tmpStream,includeSource)
	}
	Quit
IndexRoutine(routinename,tmpStream,includeSource)
	Quit:routinename=""
	Quit:'$IsObject(tmpStream)
	
	Do tmpStream.Clear()
	
	// Replace existing data
	set line=0
	
	//set seq=routinename_$C(10)
	set lineNumber=0
	set currentLabel=routinename  // Typical M convention
	set currentLabelData=""
	set isMultiLineComment=0
	for {
		set lineNumber=$Order(^rMAC(routinename,0,lineNumber),+1,data)
		// There is additional routine information following the Routine lines which are ignored
		quit:lineNumber'?1.N
		
		set tmpdata1=$ZSTRIP(data,"<>W")
		// Simple handling for multiline comments
		// assumes first two characters on line for start multiline comment is "/*"
		// and end two characters for end multiline comment is "*/"
		// Utility is to skip commented-out line labels to pick these up as content difference
		if 'isMultiLineComment,$E(tmpdata1,1,2)="/*" {
			// Start of multiline comment
			set isMultiLineComment=1
			continue
		} elseif isMultiLineComment,$E(tmpdata1,*-1,*)="*/" {
			// End of multiline comment
			set isMultiLineComment=0
			continue	
		} elseif isMultiLineComment	{
			// Continue multiline comment
			continue	
		}
		
		set data=$ZSTRIP(data,">W")
		continue:data=""
		if $E(data,1)?1(1A,1"%") {
		  // Process as Start of Line Label	
		  // Get the line label name
		  set nextLabel=""
		  for i=1:1:32 {
			 set char=$E(data,i)
			 quit:char=""
			 if i>1,char?1P quit
			 // Append character to next linelabel name
			 set nextLabel=nextLabel_char
		  }

		  if nextLabel'=currentLabel,tmpStream.Size>0 {
			
			Do tmpStream.Rewind()
			set sig=$SYSTEM.Encryption.Base64Encode($SYSTEM.Encryption.SHA1HashStream(tmpStream))
			Do SetSignature(routinename, sig,$$$RPTSubTypeLineLabel,currentLabel)
			Do:includeSource SaveLines(sig)
			
			set currentLabel=nextLabel
			// Logging
			Do:logging tmpStream.Rewind()
			Do:logging tmpStream.OutputToDevice()
			
			Do tmpStream.Clear()
			set line=0
			Do WriteLine(tmpStream,data)
			
		  } else {
			Do WriteLine(tmpStream,data)
		  }
		  
		} else {
			set tmpdata1=$ZSTRIP(data,"<W")
			if tmpdata1="" {
				continue
			}
			if $E(tmpdata1,1)=";",$E(tmpdata1,2)'=";" {
				// Exclude single line comment except when used
				// as TEXT comments which may have functional differences between code
				continue
			}
			if $E(tmpdata1,1,2)="//" {
				continue
			}
			Do WriteLine(tmpStream,data)
		}
	
	}
	if currentLabel'="",tmpStream.Size>0 {

		Do tmpStream.Rewind()
		set sig=$SYSTEM.Encryption.Base64Encode($SYSTEM.Encryption.SHA1HashStream(tmpStream))
		Do SetSignature(routinename, sig,$$$RPTSubTypeLineLabel,currentLabel)
		Do:includeSource SaveLines(sig)
		
		Do tmpStream.Clear()
	}
	
	set routineSummary=routinename
	// After completing detail for line labels make a signature for the whole routine
	// Note that the order of the line labels is not functionally important
	set currentLabel=""
	for {
		Quit:'$$NextSignature(routinename,.sig,$$$RPTSubTypeLineLabel,.currentLabel)
		set routineSummary=routineSummary_";"_currentLabel_":"_sig
	}
	
	Do SetSignature(routinename, $SYSTEM.Encryption.Base64Encode($SYSTEM.Encryption.SHA1Hash(routineSummary)))
	
	Do SetIsMapped(routinename)
	Do SetIsSourceControlled(routinename)
	// Exit Line label
	Quit

	/***********************
	  End Indexer Specific code
	************************/
	Quit
}

}

