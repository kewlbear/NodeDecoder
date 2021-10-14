# NodeDecoder

Swift package of a decoder for Node.js values.

## Usage

```
struct Foo: Codable {
    // ...
}

let foo = try NodeDecoder(env: env).decode(Foo.self, from: value)
```

### Swift Package Manager

```
.package(url: "https://github.com/kewlbear/NodeDecoder.git", .branch("main")),
```

## License

MIT
