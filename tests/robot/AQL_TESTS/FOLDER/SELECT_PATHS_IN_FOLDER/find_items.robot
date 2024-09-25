*** Settings ***
Documentation   CHECK SELECT PATHS IN FOLDER - Find Items
...         - Covers: https://github.com/ehrbase/conformance-testing-documentation/blob/main/FOLDER.md#find-items
...         - *Precondition:*
...         - 1. Upload OPT; 2. Create EHR;
...         - 3. Create 2 compositions with conformance_ehrbase.de.v0_max.json and store their compo_ids;
...         - 4. Create Directory with folder_multi_compositions.json;
...         - 5. Create 1 composition with conformance_ehrbase.de.v0_max.json;
...         - Send AQL query and compare response body with expected file content.
...         - *Postcondition:* Delete EHR using ADMIN endpoint.
Resource        ../../../_resources/keywords/aql_keywords.robot

Suite Setup     Precondition
Suite Teardown  Admin Delete EHR For AQL

*** Variables ***
${q}   SELECT f/uid/value, f/name/value, f/archetype_node_id, f/items/id/value FROM FOLDER f


*** Test Cases ***
Find Items: ${q}
    Set Test Variable   ${query}    ${q}
    ${temporary_file}   Set Variable
    ...     ${EXPECTED_JSON_DATA_SETS}/folder/expected_folder_find_items_tmp.json
    Set AQL And Execute Ad Hoc Query    ${query}
    Length Should Be    ${resp_body['rows']}     2
    ${expected_file}    Set Variable      expected_folder_find_items.json
    ${expected_res_tmp}     Set Variable   ${EXPECTED_JSON_DATA_SETS}/folder/${expected_file}
    ${file_without_replaced_vars}   Get File    ${expected_res_tmp}
    ${data_replaced_vars}    Replace Variables  ${file_without_replaced_vars}
    Create File     ${temporary_file}
    ...     ${data_replaced_vars}
    ${exclude_paths}    Create List    root['meta']     root['q']
    ${diff}     compare json-string with json-file
    ...     ${resp_body_actual}     ${temporary_file}   exclude_paths=${exclude_paths}
    ...		ignore_string_case=${TRUE}
    Should Be Empty    ${diff}    msg=DIFF DETECTED!
    [Teardown]      Remove File     ${temporary_file}



*** Keywords ***
Precondition
    Set Library Search Order For Tests
    Upload OPT For AQL      conformance_ehrbase.de.v0.opt
    Create EHR For AQL
    Commit Composition For AQL      conformance_ehrbase.de.v0_max.json
    Set Suite Variable      ${c_uid1}   ${composition_short_uid}
    Commit Composition For AQL      conformance_ehrbase.de.v0_max.json
    Set Suite Variable      ${c_uid2}   ${composition_short_uid}
    Create Directory For AQL    folder_multi_compositions.json   has_robot_vars=${TRUE}
    Commit Composition For AQL      conformance_ehrbase.de.v0_max.json