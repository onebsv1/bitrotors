const std = @import("std");
const tallocator = std.testing.allocator;
const warn = std.debug.warn;
const assertEqual = std.testing.expectEqual;

pub fn sweep(allocat: *std.mem.Allocator, bits: u128, r: u128) !*std.ArrayList(u128){
    var i: u128 = 0;
    var index: usize = 0;
    var collect  = std.ArrayList(u128).init(allocat);
    errdefer collect.deinit();
    var omasks: []u128 = allocat.alloc(u128, @intCast(usize, r)) catch unreachable;
    defer allocat.free(omasks);
    var mask: u128 = 0;
    while ( i < r ) : (i += 1) {
        mask |= @intCast(u128, 1) <<  @truncate(std.math.Log2Int(u128), i);
    }
    var omask = mask;
    var u: u128 = i-1;
    var ind: usize = 0;
    while ( u > 0 ) : ( u-=1 ) {
        omask &= ~( @intCast(u128, 1) << @truncate(std.math.Log2Int(u128), i) );
        omasks[ind] = omask;
        ind += 1;
    }
    var j: usize = 0;
    var z: u128 = i-j;
    while ( j < r-1) : ( j+= 1) {
        z = i-j;
        mask = omasks[j];
        var k: usize = j;
        while ( k > 0 ) : ( k-=1 ) {
            mask |= @intCast(u128, 1) << @truncate(std.math.Log2Int(u128), (bits-1)-k);
        }
        while ( z < ((bits-1)-j) ) : ( z += 1 ) {
            mask |= @intCast(u128, 1) << @truncate(std.math.Log2Int(u128), z);
            try collect.append(mask);
            index += 1;
            mask &= ~(@intCast(u128, 1) << @truncate(std.math.Log2Int(u128), z));
        }
    }
    mask = collect.items[index-1] & ~@intCast(u128, 1) <<  @truncate(std.math.Log2Int(u128), 0);
    var v: u8 = 1;
    while( v < ( (bits-1) - (r-1)  ) ) : ( v += 1){
        mask |= @intCast(u128, 1) << @truncate(std.math.Log2Int(u128), v);
        try collect.append(mask);
        index += 1;
        mask &= ~(@intCast(u128, 1) << @truncate(std.math.Log2Int(u128), v));
    }
    return &collect;
}

test "sweep" {
    var res = sweep(tallocator, 128, 5) catch unreachable;
    defer res.deinit();

    var idx: usize = 0;
    while (idx < res.items.len) : (idx += 1) {
        warn("mask: {b}\r\n", .{res.items[idx]});
    }
}
