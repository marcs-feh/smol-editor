
When possible, keep things in `core` header-only. Split into .cpp/.hpp when you
need to hide implementation details or do platform specific things.

Don't splatter `constexpr` everywhere unless it is:

1. A very primitive, pure function ("Math stuffs")
2. Really necessary to define constants somewhere else

