Include %occInclude

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
/// Base class Template for SourceHandler implementations.<br/>
/// This class would be of interest for persons who wish to implement additional
/// differencing functionality for other document types or environment parameters
/// not already provided by the ompare package.<br/>
/// Builds highlevel Signatures of implementation and <em>optionally</em> captures functional Source code.<br/>
/// The job of a SourceHander is to analyse code or environment configuration or state
/// and generate data that an be exported to flat file. Later these files can be 
/// transferred to a reporting service thus allowing comparison of disconnected systems.
/// SourceHandlers like Schedule are imported only into one namespace on a client server.
/// Only these <em>client</em> components of ompare package are needed to generate signature 
/// information.
/// The schedule detects sub-classes of the base class and will attempt to run them
/// where imported to the run namespace.
/// To exclude particular SourceHandlers, simply do not load them into the target run namespace.
/// The use of "Sub-Classing" Base allows the schedule to <em>Discover</em> and <em>Run</em> new Source Handler implementations added to a system.<br/>
/// The implementation pattern with line labels within the IndexNamespace Method is necessary in order
/// to retain functionality when switching namespace during execution.
/// See other SourceHandler implementation for examples defining macros
/// <ul><li>RPTType</li>
/// <li>RPTSubType___</li>
/// <li>RPTItemConfig___</li>
/// </ul>
/// Take care to define unique Type and SubType values across existing SourceHandlers.<br/>
/// The task of a SourceHandler is to build up ^||Data and ^||DataSrc process private gloabls
/// to represent source implmentation signatures and optionally extract source code sections.
/// LineLable <em>SetSignature</em> generates ^||Data entries for highlevel reporting
/// Optionally Line labels <em>AddLine</em> and <em>SaveLines</em> generate ^||DataSrc
/// for detailed difference reporting when appropriate.<br/>
/// Line label <em>IsExcluded</em> provides support exclusions for one or more source code
/// items for example classname or routinename.
/// Suggest use exclusions in the most permissible case to capture all possible areas
/// needed for reporting.
/// Subsequently reports can be defined that are configured to give different slices 
/// and or filtered views of analysed code.
/// Exclude configuration leverages entries in ensemble lookuptable "ompare.Exclude" where
/// <example>
/// ^ompare("Config","Exclude",key_".extension")=value
/// </example>
/// To exclude System classes by package prefix
/// <example>
/// ^ompare("Config","Exclude","%*.cls")=0
/// </example>
/// To include user class by full classname:
/// <example>
/// ^ompare("Config","Exclude","ompare.SourceHandler.Base.cls")=1
/// </example>
/// Value is either "1" (include for processing), "0" (don't include for processing)
/// Rationale. 
/// <ol><li>Reuse existing SMP page to create, and edit lookup table.</li>
/// <li>Each namespace has an independent configuration for how the SourceHandler should 
/// include source items</li></ol>
/// Exclusions can layer for example to exclude all classes within package "ompare"
/// except do include analysis of the SourceHandler subpackage:
/// <example>
/// ^ompare("Config","Exclude","ompare.*.cls")=1
/// ^ompare("Config","Exclude","ompare.SourceHandler.*.cls")=0
/// </example>
/// SourceHandlers implemented in ompare package will add default exclusion entries
/// to namespaces when run for a first time, where no existing entries are found
/// for a given document type for example: "*.cls" or "*.mac"
Class ompare.SourceHandler.Base [ Abstract ]
{

/// When Invoke per namespace is "0"
/// the Index method will be called once only.<br/>
/// When InvokePerNamespace is "1"
/// the Index method will be called for each Namespace that is managed</br>
Parameter InvokePerNamespace = 1;

/// Ensure this Code doesn't collide with other sub-class implementations of Base
/// Eg: "CLS" abbreviation for class
Parameter TypeCode As %String;

/// Do not invoke supporting methods on this class definition
ClassMethod IndexNamespace(namespace = "", logging = 0, includeSource = 0, schedule As ompare.Schedule) As %Status
{
	#define RPTType "?"
	
	/*****************************
	 Start Template
	******************************/
	#dim tmpStream as %Stream.TmpCharacter
	Set tmpStream=##class(%Stream.TmpCharacter).%New()
	// It is necessary to switch namespace context within the method call as source code may not be 
	// deployed to target namespace
	set ret=$$$OK
	
	if '..#InvokePerNamespace {
		Quit:namespace=""
	
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
	}
	
	// Invoke sub-class extension code
	Do IndexerMain
	
	Quit ret
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
  Do tmpStream.WriteLine(data)
  Do:includeSource AddLine($I(line),data)
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
Log(label, value)
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
	
	//Do Log("Start",$ZDT($H,3))
	//Do SetSignature("Class1","sig")
	//Do SetSignature("Class1","sig","PROP","TESTPROP")
	//Do Log("End",$ZDT($H,3))
	/***********************
	  End Indexer Specific code
	************************/
	Quit
}

}

