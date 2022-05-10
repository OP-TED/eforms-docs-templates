= Business Rules

The following Business Rules are included in version X.X.X of eForms SDK.

<#list notice_types as noticeType>
== ${noticeType.noticeId!"Every notice sub-type"}

<#list noticeType.ruleTypes as ruleType>
=== ${ruleType.type!"-"}

</#list>

<#if noticeType.noticeId?has_content!false>
xref:business-rules/notice-type-${noticeType.noticeId}.adoc[See details]
</#if>

</#list>