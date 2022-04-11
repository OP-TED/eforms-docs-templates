= Business Rules

The following Business Rules are included in version X.X.X of eForms SDK.

<#list business_rules as noticeType>
== ${noticeType.notice_id!"Every notice sub-type"}
Blah blah

<#list noticeType.types as ruleType>
=== ${ruleType.type!"-"}
[cols="<2,<7,>1"]
|====
h| Field h|Details h|Severity 
<#list ruleType.rules as rule>
h|<#if rule.field_id?has_content!false>`${rule.field_id}`</#if>
|<#if rule.pattern_id?has_content!false>Pattern: `${rule.pattern_id}`</#if>
<#if rule.interval_id?has_content!false>Interval: `${rule.interval_id}`</#if>
<#if rule.code_list_id?has_content!false>Codelist: `${rule.code_list_id}`</#if>
<#if rule.condition_id?has_content!false>Condition: `${rule.condition_id}`</#if>
|<#if rule.severity?has_content!false>${rule.severity}</#if>
</#list>
|====

</#list>

</#list>
