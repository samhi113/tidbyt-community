"""
Applet: 3CellularAutomata
Summary: Draws 1D cellular automata
Description: Draws the evolution of one-dimensional, three-state cellular automata.
Author: dinosaursrarr
"""

load("math.star", "math")
load("random.star", "random")
load("render.star", "render")
load("schema.star", "schema")
load("time.star", "time")

WIDTH = 64
HEIGHT = 32
REFRESH_MILLISECONDS = 200
CHOOSE_RANDOM = "-"
SINGLE_CELL = "+"
STATES = 3

COLOURS = [
    schema.Option(display = "White", value = "#ffffff"),
    schema.Option(display = "Silver", value = "#c0c0c0"),
    schema.Option(display = "Gray", value = "#808080"),
    schema.Option(display = "Black", value = "#000000"),
    schema.Option(display = "Red", value = "#ff0000"),
    schema.Option(display = "Maroon", value = "#800000"),
    schema.Option(display = "Yellow", value = "#ffff00"),
    schema.Option(display = "Olive", value = "#808000"),
    schema.Option(display = "Lime", value = "#00ff00"),
    schema.Option(display = "Green", value = "#008000"),
    schema.Option(display = "Aqua", value = "#00ffff"),
    schema.Option(display = "Teal", value = "#008080"),
    schema.Option(display = "Blue", value = "#0000ff"),
    schema.Option(display = "Navy", value = "#000080"),
    schema.Option(display = "Fuchsia", value = "#ff00ff"),
    schema.Option(display = "Purple", value = "#800080"),
]

DEFAULT_COLOURS = [
    3,  # Black
    0,  # White
    12,  # Blue
]

def neighbours_to_ternary(left, middle, right):
    return (left * STATES * STATES) + (middle * STATES) + right

def next_row(current_row, rule):
    new_row = []
    for i in range(len(current_row)):
        left = current_row[i - 1]
        middle = current_row[i]
        right = current_row[(i + 1) % len(current_row)]
        scenario = neighbours_to_ternary(left, middle, right)
        child = math.floor(rule / math.pow(STATES, scenario)) % STATES
        new_row.append(child)
    return new_row

def render_grid(grid, cells):
    return render.Column(
        children = [
            render.Row(
                children = [cells[c] for c in row],
            )
            for row in grid
        ],
    )

def animate(cells, rule, starting_row):
    frames = []

    first_row = [0] * WIDTH
    if starting_row == SINGLE_CELL:
        first_row[math.ceil(WIDTH / 2)] = 1
    elif starting_row == CHOOSE_RANDOM:
        for i in range(len(first_row)):
            first_row[i] = math.floor(random.number(0, 1) / (1 / STATES))
            if first_row[i] == STATES:
                first_row[i] = STATES - 1

    grid = [first_row]
    frames.append(render_grid(grid, cells))

    for _ in range(HEIGHT):
        row = next_row(grid[-1], rule)
        grid.append(row)
        frames.append(render_grid(grid, cells))

    return render.Animation(children = frames)

def main(config):
    colours = []
    for s in range(STATES):
        colour = config.get("state_{}_colour".format(s))
        if not colour:
            colour = COLOURS[DEFAULT_COLOURS[s]].value
        colours.append(colour)

    # Turns out to be significantly faster to re-use
    # a single element rather than create one for each
    # cell on each iteration.
    cells = [
        render.Box(
            width = 1,
            height = 1,
            color = c,
        )
        for c in colours
    ]

    starting_row = config.get("starting_row")
    if not starting_row:
        starting_row = SINGLE_CELL

    # seed the RNG with a new value every 15 seconds to improve
    # cross-user caching.
    random.seed(time.now().unix // 15)
    rule = random.number(0, int(math.pow(STATES, math.pow(STATES, 3))))
    print("Using rule {}".format(rule))

    return render.Root(
        delay = REFRESH_MILLISECONDS,
        child = animate(cells, rule, starting_row),
    )

def get_schema():
    return schema.Schema(
        version = "1",
        fields = [
            schema.Dropdown(
                id = "state_{}_colour".format(s),
                name = "State {} colour".format(s),
                desc = "The colour to show for cells in state {}".format(s),
                icon = "palette",
                default = COLOURS[DEFAULT_COLOURS[s]].value,
                options = COLOURS,
            )
            for s in range(STATES)
        ] + [
            schema.Dropdown(
                id = "starting_row",
                name = "Starting row",
                desc = "Determine starting conditions",
                icon = "play",
                default = SINGLE_CELL,
                options = [
                    schema.Option(display = "Random", value = CHOOSE_RANDOM),
                    schema.Option(display = "Single cell", value = SINGLE_CELL),
                ],
            ),
        ],
    )
