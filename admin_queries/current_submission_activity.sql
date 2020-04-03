WITH assessments_with_submission_counts AS (
    SELECT
        a.id AS assessment_id,
        count(*) AS submission_count
    FROM
        submissions AS s
        JOIN variants AS v ON (v.id = s.variant_id)
        JOIN instance_questions AS iq ON (iq.id = v.instance_question_id)
        JOIN assessment_instances AS ai ON (ai.id = iq.assessment_instance_id)
        JOIN assessments AS a ON (a.id = ai.assessment_id)
    WHERE s.date > now() - interval '10 minutes'
    GROUP BY a.id
    LIMIT 100
)
SELECT
    i.short_name AS institution,
    c.short_name AS course,
    c.id AS course_id,
    ci.short_name AS course_instance,
    ci.id AS course_instance_id,
    aset.abbreviation || a.number || ': ' || a.title AS assessment,
    a.id AS assessment_id,
    awsc.submission_count
FROM
    assessments_with_submission_counts AS awsc
    JOIN assessments AS a ON (a.id = awsc.assessment_id)
    JOIN assessment_sets AS aset ON (aset.id = a.assessment_set_id)
    JOIN course_instances AS ci ON (ci.id = a.course_instance_id)
    JOIN pl_courses AS c ON (c.id = ci.course_id)
    JOIN institutions AS i ON (i.id = c.institution_id)
ORDER BY
    awsc.submission_count DESC;
