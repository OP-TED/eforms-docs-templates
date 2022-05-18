== Business rules for notice sub-type `${notice_type_details.noticeId}`

<#list notice_type_details.ruleTypes as ruleType>
=== `${ruleType.type!"-"}`
[cols="<2,<7,>1"]
|====
h| Field h|Details h|Severity 
<#list ruleType.rules as rule>
h|<#if rule.fieldId?has_content!false>`${rule.fieldId}`</#if>
a|<#if rule.pattern?has_content!false>
[source, RegEx, subs="none"]
----
${rule.pattern.id} ${rule.pattern.value}
----
</#if>
<#if rule.interval?has_content!false>Interval: `${rule.interval.id} ${rule.interval.lowerValue} - ${rule.interval.higherValue}`</#if>
<#if rule.codeListId?has_content!false>Codelist: `${rule.codeListId}`</#if>
<#if rule.condition?has_content!false>
[source, EFX]
----
${rule.condition.expressionEfx}
----

_Applies when: ${rule.condition.description}_
<#else>
_Applies: ALWAYS_
</#if>
|<#if rule.severity?has_content!false>${rule.severity}</#if>
</#list>
|====

</#list>