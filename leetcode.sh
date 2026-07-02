# !/usr/bin/env bash

# A Simple script to get the num of solved problems
# from leetcode-cn

# Replace your username here
# https://leetcode.cn/u/[username]
UserName="yilozt"

# Payload for POST request
post_raw() {
    local raw=$(sed 's/<USER_SLUG>/'${UserName}'/' ./post_raw)
    echo "${raw//$'\n'/\\n}"
}

# Send POST request to leetcode.cn
request_solved() {
    curl 'https://leetcode.cn/graphql/' -X POST \
    -H 'Content-Type: application/json'         \
    --data-raw "$(post_raw)"
}

# Parse the response, json format
parse_counts() {
    local response="${1}"
    local query_type="${2}"

    local query=".data.userProfileUserQuestionProgress.${query_type}[]|.count"

    echo "${response}" | jq "${query}"
}

parse_jq() {
    local response=$(request_solved)

    local solved_cnt=$(parse_counts "${response}"    "numAcceptedQuestions")
    local untouched_cnt=$(parse_counts "${response}" "numUntouchedQuestions")
    local failed_cnt=$(parse_counts "${response}"    "numFailedQuestions")

    local labels="easy medium hard"

    local total_solved=0
    for (( i = 1; i <=3; i++ )); do
        local solved=$(echo ${solved_cnt} | cut -d ' ' -f $i)
        (( total_solved += solved ))
    done
    echo "solved =" ${total_solved}

    for (( i = 1; i <=3; i++ )); do
        local solved=$(echo ${solved_cnt}       | cut -d ' ' -f $i)
        local untouched=$(echo ${untouched_cnt} | cut -d ' ' -f $i)
        local failed=$(echo ${failed_cnt}       | cut -d ' ' -f $i)
        local label=$(echo ${labels}            | cut -d ' ' -f $i)

        local total=$((solved + untouched + failed))
        echo ${label} = ${solved} / ${total}
    done
}

run() {
    local content="$(parse_jq)"
    sed -ri "s|<!--LEETCODE-->|${content//$'\n'/\\n}|" readme.md
}

run