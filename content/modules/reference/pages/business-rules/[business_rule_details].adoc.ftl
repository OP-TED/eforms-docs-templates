////
We need a page for every business rule.
The page will display all the details about the rule.
////

== ${business_rule_details.noticeId!"Every notice sub-type"}
Blah blah

<#list business_rule_details.ruleTypes as ruleType>
=== ${ruleType.type!"-"}
[cols="<2,<7,>1"]
|====
h| Field h|Details h|Severity 
<#list ruleType.rules as rule>
h|<#if rule.fieldId?has_content!false>`${rule.fieldId}`</#if>
|<#if rule.patternId?has_content!false>Pattern: `${rule.patternId}`</#if>
<#if rule.intervalId?has_content!false>Interval: `${rule.intervalId}`</#if>
<#if rule.codeListId?has_content!false>Codelist: `${rule.codeListId}`</#if>
<#if rule.conditionId?has_content!false>Condition: `${rule.conditionId}`</#if>
|<#if rule.severity?has_content!false>${rule.severity}</#if>
</#list>
|====

</#list>
