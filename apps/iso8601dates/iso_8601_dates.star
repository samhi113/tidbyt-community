"""
Applet: ISO 8601 Dates
Summary: Display ISO8601 Dates
Description: Display different ISO8601 date formats.
Author: jvivona
"""

load("schema.star", "schema")
load("time.star", "time")
load("math.star", "math")


def main(config):
    current_time = time.now().in_location(config.get("$tz", "America/New_York"))
    to_replace = str(current_time.format("01-02"))
    curr_date = str(current_time.format("2006-01-02 15:04:05 -0700"))

    jan1 = curr_date.replace(to_replace, "01-01")
    jan1_time = time.parse_time(jan1, "2006-01-02 15:04:05 -0700", location = "America/New_York")

    datediff = current_time - jan1_time

    # we are always going to display days - so we can calc in main - no horsepower lost
    days = str(math.floor(datediff.hours // 24) + 1)
    for _ in range(0, 3 - len(days)):
        days = "0" + days

    print(days)
    print("{} {}".format(current_time.format("06"), days))
    print(current_time.format("Monday January 2, 2006"))

    return []