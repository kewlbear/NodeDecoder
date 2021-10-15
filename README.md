# NodeDecoder

Swift package of a decoder for Node.js values.

## Usage

```
struct Foo: Codable {
    // ...
}

let foo = try NodeDecoder(env: env).decode(Foo.self, from: value)
```

For a real world example app, see https://github.com/kewlbear/Inssagram.

### Swift Package Manager

```
.package(url: "https://github.com/kewlbear/NodeDecoder.git", .branch("main")),
```

## License

MIT
