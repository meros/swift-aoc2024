# Advent of Code 2024 in Swift

My solutions to [Advent of Code 2024](https://adventofcode.com/2024), written in Swift during December 2024. Each day is its own target in one Swift package, and a small runner fetches the puzzle input, runs both parts and times them.

## Requirements

- Swift 5.7 or later
- macOS 13 or later (set in `Package.swift`)
- An Advent of Code session cookie

## How to run

Save your session cookie from adventofcode.com in a file named `.session` in the repository root. The runner uses it to download your puzzle input and caches it in `.cache/day<N>.txt`. Both paths are in `.gitignore`.

Run one day:

```bash
swift run -c release Main 7
```

Run all 25 days:

```bash
swift run -c release Main
```

Each part is checked against the answer stored in that day's `Solution.swift`. A day that sets `onlySolveExamples` to `true` runs on `.cache/day<N>.example.txt` instead.

## Layout

- `Sources/DayNN/Solution.swift`: the solution for day NN
- `Sources/Utils`: input loading, grid helpers and an A* search
- `Sources/template`: the starting point for a new day
- `Sources/Main`: the runner

## Status

Done. All 25 days are solved.

## License

0BSD. See [LICENSE](LICENSE).
