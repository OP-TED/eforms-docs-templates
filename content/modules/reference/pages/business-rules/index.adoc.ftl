= Business Rules
The following Business Rules are included in version X.X.X of eForms SDK.

== Rules applicable to every notice sub-type
<#if rules_without_notice_sub_type?has_content>
${rules_without_notice_sub_type?map(rt -> rt.type)?join(", ")}
</#if>

== Applicable rules by notice sub-type
<#if notice_sub_types?has_content>
${notice_sub_types?map(nst -> "xref:business-rules/notice-subtype-" + nst.noticeId + ".adoc[" + nst.noticeId + "]")?join(", ")}
</#if>
