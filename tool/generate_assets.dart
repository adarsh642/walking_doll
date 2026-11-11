// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

void main() {
  print('Generating bundled demo assets...');

  // 1. Generate Sakura Idle (128x128 RGBA PNG)
  final sakuraBytes = generateChibiPng(
    width: 128,
    height: 128,
    hairColor: const [255, 140, 180, 255], // Soft pink
    skinColor: const [255, 230, 215, 255],
    dressColor: const [180, 160, 240, 255], // Lavender
  );
  File('assets/characters/2d/sakura_idle.png').writeAsBytesSync(sakuraBytes);
  print('Generated assets/characters/2d/sakura_idle.png');

  // 2. Generate Mochi Cat 4x1 Sprite Sheet (256x64 RGBA PNG, each frame 64x64)
  final mochiCatSpriteBytes = generateCatSpriteSheetPng(width: 256, height: 64);
  File('assets/characters/2d/mochi_cat_spritesheet.png').writeAsBytesSync(mochiCatSpriteBytes);
  print('Generated assets/characters/2d/mochi_cat_spritesheet.png');

  // 3. Generate Starry Bunny (128x128 RGBA PNG)
  final bunnyBytes = generateBunnyPng(width: 128, height: 128);
  File('assets/characters/2d/starry_bunny.png').writeAsBytesSync(bunnyBytes);
  print('Generated assets/characters/2d/starry_bunny.png');

  // 4. Generate App Icon/Logo (128x128 RGBA PNG)
  final logoBytes = generateLogoPng(width: 128, height: 128);
  File('assets/icons/app_logo.png').writeAsBytesSync(logoBytes);
  print('Generated assets/icons/app_logo.png');

  // 5. Generate Astro Doll 3D GLB Model with embedded animation
  final astroGlbBytes = generateAstroDollGlb();
  File('assets/characters/3d/astro_doll.glb').writeAsBytesSync(astroGlbBytes);
  print('Generated assets/characters/3d/astro_doll.glb');

  // 6. Generate Prism Star 3D GLB Model (faceted gem for fallback idle testing)
  final prismGlbBytes = generatePrismStarGlb();
  File('assets/characters/3d/prism_star.glb').writeAsBytesSync(prismGlbBytes);
  print('Generated assets/characters/3d/prism_star.glb');

  print('All demo assets generated successfully!');
}

/// Simple CRC32 implementation for PNG chunks
int crc32(List<int> bytes) {
  int crc = 0xFFFFFFFF;
  for (final byte in bytes) {
    crc ^= byte;
    for (int i = 0; i < 8; i++) {
      if ((crc & 1) != 0) {
        crc = (crc >>> 1) ^ 0xEDB88320;
      } else {
        crc = crc >>> 1;
      }
    }
  }
  return crc ^ 0xFFFFFFFF;
}

Uint8List createPngChunk(String type, Uint8List data) {
  final typeBytes = ascii.encode(type);
  final length = data.length;
  final buffer = BytesBuilder();

  final lenBytes = ByteData(4)..setUint32(0, length, Endian.big);
  buffer.add(lenBytes.buffer.asUint8List());
  buffer.add(typeBytes);
  buffer.add(data);

  final crcData = <int>[...typeBytes, ...data];
  final crcVal = crc32(crcData);
  final crcBytes = ByteData(4)..setUint32(0, crcVal, Endian.big);
  buffer.add(crcBytes.buffer.asUint8List());

  return buffer.toBytes();
}

Uint8List encodeRgbaPng(int width, int height, List<List<int>> pixels) {
  final rawScanlines = BytesBuilder();
  for (int y = 0; y < height; y++) {
    rawScanlines.addByte(0); // Filter type None
    for (int x = 0; x < width; x++) {
      final color = pixels[y * width + x];
      rawScanlines.addByte(color[0]); // R
      rawScanlines.addByte(color[1]); // G
      rawScanlines.addByte(color[2]); // B
      rawScanlines.addByte(color[3]); // A
    }
  }

  final compressed = zlib.encode(rawScanlines.toBytes());

  final png = BytesBuilder();
  // PNG signature
  png.add([137, 80, 78, 71, 13, 10, 26, 10]);

  // IHDR
  final ihdrData = ByteData(13)
    ..setUint32(0, width, Endian.big)
    ..setUint32(4, height, Endian.big)
    ..setUint8(8, 8) // Bit depth 8
    ..setUint8(9, 6) // Color type RGBA
    ..setUint8(10, 0) // Compression
    ..setUint8(11, 0) // Filter
    ..setUint8(12, 0); // Interlace
  png.add(createPngChunk('IHDR', ihdrData.buffer.asUint8List()));

  // IDAT
  png.add(createPngChunk('IDAT', Uint8List.fromList(compressed)));

  // IEND
  png.add(createPngChunk('IEND', Uint8List(0)));

  return png.toBytes();
}

Uint8List generateChibiPng({
  required int width,
  required int height,
  required List<int> hairColor,
  required List<int> skinColor,
  required List<int> dressColor,
}) {
  final pixels = List.generate(width * height, (_) => [0, 0, 0, 0]);

  void setPixel(int x, int y, List<int> c) {
    if (x >= 0 && x < width && y >= 0 && y < height) {
      pixels[y * width + x] = c;
    }
  }

  void drawCircle(double cx, double cy, double r, List<int> color) {
    final minX = (cx - r).floor();
    final maxX = (cx + r).ceil();
    final minY = (cy - r).floor();
    final maxY = (cy + r).ceil();

    for (int y = minY; y <= maxY; y++) {
      for (int x = minX; x <= maxX; x++) {
        final dist = math.sqrt((x - cx) * (x - cx) + (y - cy) * (y - cy));
        if (dist <= r) {
          setPixel(x, y, color);
        }
      }
    }
  }

  // Draw background glow/shadow
  drawCircle(64, 115, 26, [220, 180, 220, 70]);

  // Draw dress / body
  for (int y = 68; y <= 110; y++) {
    final halfW = 10 + (y - 68) * 0.45;
    for (int x = (64 - halfW).floor(); x <= (64 + halfW).ceil(); x++) {
      setPixel(x, y, dressColor);
    }
  }
  // Dress collar
  drawCircle(64, 70, 7, [255, 255, 255, 255]);

  // Draw Head
  drawCircle(64, 50, 28, skinColor);

  // Hair back / buns
  drawCircle(38, 36, 15, hairColor);
  drawCircle(90, 36, 15, hairColor);
  // Hair ribbons
  drawCircle(38, 36, 6, [255, 90, 130, 255]);
  drawCircle(90, 36, 6, [255, 90, 130, 255]);

  // Hair front & bangs
  for (int y = 24; y <= 46; y++) {
    for (int x = 40; x <= 88; x++) {
      final dist = math.sqrt((x - 64) * (x - 64) + (y - 50) * (y - 50));
      if (dist <= 30 && y < 44 + (math.sin(x * 0.4) * 4)) {
        setPixel(x, y, hairColor);
      }
    }
  }

  // Eyes (Big cute anime style)
  drawCircle(53, 52, 5, [60, 40, 80, 255]);
  drawCircle(75, 52, 5, [60, 40, 80, 255]);
  // Eye highlights
  drawCircle(51, 50, 2, [255, 255, 255, 255]);
  drawCircle(73, 50, 2, [255, 255, 255, 255]);

  // Blushes
  drawCircle(46, 58, 4, [255, 140, 160, 180]);
  drawCircle(82, 58, 4, [255, 140, 160, 180]);

  // Smile
  drawCircle(64, 60, 2, [220, 90, 110, 255]);

  // Shoes
  drawCircle(54, 112, 6, [255, 110, 150, 255]);
  drawCircle(74, 112, 6, [255, 110, 150, 255]);

  return encodeRgbaPng(width, height, pixels);
}

Uint8List generateCatSpriteSheetPng({required int width, required int height}) {
  final pixels = List.generate(width * height, (_) => [0, 0, 0, 0]);

  void setPixel(int x, int y, List<int> c) {
    if (x >= 0 && x < width && y >= 0 && y < height) {
      pixels[y * width + x] = c;
    }
  }

  void drawCircle(double cx, double cy, double r, List<int> color) {
    final minX = (cx - r).floor();
    final maxX = (cx + r).ceil();
    final minY = (cy - r).floor();
    final maxY = (cy + r).ceil();
    for (int y = minY; y <= maxY; y++) {
      for (int x = minX; x <= maxX; x++) {
        final dist = math.sqrt((x - cx) * (x - cx) + (y - cy) * (y - cy));
        if (dist <= r) {
          setPixel(x, y, color);
        }
      }
    }
  }

  // 4 frames of 64x64
  for (int f = 0; f < 4; f++) {
    final ox = f * 64.0;
    final bob = (f == 1 || f == 3) ? -3.0 : (f == 2 ? -6.0 : 0.0);

    // Body
    drawCircle(ox + 32, 40 + bob, 16, [250, 250, 252, 255]);
    // Head
    drawCircle(ox + 32, 26 + bob, 14, [250, 250, 252, 255]);

    // Ears
    drawCircle(ox + 22, 16 + bob, 5, [255, 180, 200, 255]);
    drawCircle(ox + 42, 16 + bob, 5, [255, 180, 200, 255]);

    // Eyes
    drawCircle(ox + 27, 26 + bob, 2.5, [40, 40, 50, 255]);
    drawCircle(ox + 37, 26 + bob, 2.5, [40, 40, 50, 255]);
    drawCircle(ox + 26, 25 + bob, 1, [255, 255, 255, 255]);
    drawCircle(ox + 36, 25 + bob, 1, [255, 255, 255, 255]);

    // Cheeks
    drawCircle(ox + 23, 29 + bob, 2.5, [255, 170, 190, 200]);
    drawCircle(ox + 41, 29 + bob, 2.5, [255, 170, 190, 200]);

    // Collar with bell
    drawCircle(ox + 32, 34 + bob, 3, [255, 200, 50, 255]);

    // Paws (animated positions per frame)
    final paw1Y = (f == 1) ? 50.0 + bob - 4 : 52.0 + bob;
    final paw2Y = (f == 3) ? 50.0 + bob - 4 : 52.0 + bob;
    drawCircle(ox + 25, paw1Y, 4, [240, 230, 235, 255]);
    drawCircle(ox + 39, paw2Y, 4, [240, 230, 235, 255]);

    // Tail
    final tailSwing = math.sin(f * math.pi / 2) * 4;
    drawCircle(ox + 48 + tailSwing, 38 + bob, 4, [250, 220, 230, 255]);
  }

  return encodeRgbaPng(width, height, pixels);
}

Uint8List generateBunnyPng({required int width, required int height}) {
  final pixels = List.generate(width * height, (_) => [0, 0, 0, 0]);

  void setPixel(int x, int y, List<int> c) {
    if (x >= 0 && x < width && y >= 0 && y < height) {
      pixels[y * width + x] = c;
    }
  }

  void drawCircle(double cx, double cy, double r, List<int> color) {
    final minX = (cx - r).floor();
    final maxX = (cx + r).ceil();
    final minY = (cy - r).floor();
    final maxY = (cy + r).ceil();
    for (int y = minY; y <= maxY; y++) {
      for (int x = minX; x <= maxX; x++) {
        final dist = math.sqrt((x - cx) * (x - cx) + (y - cy) * (y - cy));
        if (dist <= r) {
          setPixel(x, y, color);
        }
      }
    }
  }

  // Soft glow
  drawCircle(64, 110, 24, [200, 240, 240, 60]);

  // Bunny Ears
  drawCircle(50, 28, 10, [255, 255, 255, 255]);
  drawCircle(50, 28, 6, [255, 190, 210, 255]);
  drawCircle(78, 28, 10, [255, 255, 255, 255]);
  drawCircle(78, 28, 6, [255, 190, 210, 255]);

  // Head
  drawCircle(64, 52, 26, [255, 255, 255, 255]);

  // Mint Bow Tie
  drawCircle(64, 76, 7, [130, 220, 205, 255]);
  drawCircle(56, 76, 5, [110, 205, 190, 255]);
  drawCircle(72, 76, 5, [110, 205, 190, 255]);

  // Body
  drawCircle(64, 92, 20, [255, 250, 252, 255]);

  // Eyes
  drawCircle(54, 50, 4, [60, 50, 70, 255]);
  drawCircle(74, 50, 4, [60, 50, 70, 255]);
  drawCircle(53, 49, 1.5, [255, 255, 255, 255]);
  drawCircle(73, 49, 1.5, [255, 255, 255, 255]);

  // Nose / mouth
  drawCircle(64, 56, 2, [255, 140, 160, 255]);

  // Star badge on ear
  drawCircle(46, 22, 3, [255, 225, 80, 255]);

  // Feet
  drawCircle(52, 108, 6, [250, 220, 230, 255]);
  drawCircle(76, 108, 6, [250, 220, 230, 255]);

  return encodeRgbaPng(width, height, pixels);
}

Uint8List generateLogoPng({required int width, required int height}) {
  final pixels = List.generate(width * height, (_) => [0, 0, 0, 0]);

  void setPixel(int x, int y, List<int> c) {
    if (x >= 0 && x < width && y >= 0 && y < height) {
      pixels[y * width + x] = c;
    }
  }

  void drawCircle(double cx, double cy, double r, List<int> color) {
    final minX = (cx - r).floor();
    final maxX = (cx + r).ceil();
    final minY = (cy - r).floor();
    final maxY = (cy + r).ceil();
    for (int y = minY; y <= maxY; y++) {
      for (int x = minX; x <= maxX; x++) {
        final dist = math.sqrt((x - cx) * (x - cx) + (y - cy) * (y - cy));
        if (dist <= r) {
          setPixel(x, y, color);
        }
      }
    }
  }

  // App round icon with pink gradient background
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      final dist = math.sqrt((x - 64) * (x - 64) + (y - 64) * (y - 64));
      if (dist <= 56) {
        final ratio = (y / height);
        final r = (255 * (1 - ratio * 0.2)).toInt();
        final g = (110 + ratio * 40).toInt();
        final b = (160 + ratio * 70).toInt();
        setPixel(x, y, [r, g, b, 255]);
      }
    }
  }

  // Sparkles
  drawCircle(64, 52, 20, [255, 255, 255, 255]);
  drawCircle(58, 50, 3, [60, 40, 70, 255]);
  drawCircle(70, 50, 3, [60, 40, 70, 255]);
  drawCircle(64, 56, 2, [255, 120, 160, 255]);
  drawCircle(36, 36, 4, [255, 240, 120, 255]);
  drawCircle(92, 36, 4, [255, 240, 120, 255]);

  return encodeRgbaPng(width, height, pixels);
}

/// Helper to build a completely valid binary glTF (.glb)
Uint8List buildGlb(Map<String, dynamic> gltfJson, Uint8List binBuffer) {
  final jsonString = jsonEncode(gltfJson);
  final jsonBytesUtf8 = utf8.encode(jsonString);

  // Pad JSON chunk to 4-byte alignment with spaces (0x20)
  final jsonPadding = (4 - (jsonBytesUtf8.length % 4)) % 4;
  final jsonChunkLength = jsonBytesUtf8.length + jsonPadding;

  // Pad BIN chunk to 4-byte alignment with zeroes (0x00)
  final binPadding = (4 - (binBuffer.length % 4)) % 4;
  final binChunkLength = binBuffer.length + binPadding;

  // Header = 12 bytes
  // JSON chunk header = 8 bytes + chunkLength
  // BIN chunk header = 8 bytes + chunkLength
  final totalLength = 12 + (8 + jsonChunkLength) + (8 + binChunkLength);

  final glb = BytesBuilder();

  // 12-byte GLB Header
  // Magic: 0x46546C67 ("glTF")
  final headerData = ByteData(12)
    ..setUint32(0, 0x46546C67, Endian.little)
    ..setUint32(4, 2, Endian.little) // Version 2
    ..setUint32(8, totalLength, Endian.little);
  glb.add(headerData.buffer.asUint8List());

  // Chunk 0: JSON Chunk
  final jsonHeader = ByteData(8)
    ..setUint32(0, jsonChunkLength, Endian.little)
    ..setUint32(4, 0x4E4F534A, Endian.little); // "JSON"
  glb.add(jsonHeader.buffer.asUint8List());
  glb.add(jsonBytesUtf8);
  for (int i = 0; i < jsonPadding; i++) {
    glb.addByte(0x20); // space
  }

  // Chunk 1: BIN Chunk
  final binHeader = ByteData(8)
    ..setUint32(0, binChunkLength, Endian.little)
    ..setUint32(4, 0x004E4942, Endian.little); // "BIN\0"
  glb.add(binHeader.buffer.asUint8List());
  glb.add(binBuffer);
  for (int i = 0; i < binPadding; i++) {
    glb.addByte(0x00);
  }

  return glb.toBytes();
}

/// Generates a valid 3D low-poly doll model with 3 named animations: idle, walk, dance!
Uint8List generateAstroDollGlb() {
  final bin = BytesBuilder();

  // Create cute low-poly box mesh for Astro Doll (head, visor, body)
  // Cube vertices (24 vertices, 8 per cube, 36 indices = 12 triangles)
  // Let's create an 8-corner cube:
  final positions = <double>[
    // Front face
    -0.5, -0.5,  0.5,
     0.5, -0.5,  0.5,
     0.5,  0.5,  0.5,
    -0.5,  0.5,  0.5,
    // Back face
    -0.5, -0.5, -0.5,
    -0.5,  0.5, -0.5,
     0.5,  0.5, -0.5,
     0.5, -0.5, -0.5,
    // Top face
    -0.5,  0.5, -0.5,
    -0.5,  0.5,  0.5,
     0.5,  0.5,  0.5,
     0.5,  0.5, -0.5,
    // Bottom face
    -0.5, -0.5, -0.5,
     0.5, -0.5, -0.5,
     0.5, -0.5,  0.5,
    -0.5, -0.5,  0.5,
    // Right face
     0.5, -0.5, -0.5,
     0.5,  0.5, -0.5,
     0.5,  0.5,  0.5,
     0.5, -0.5,  0.5,
    // Left face
    -0.5, -0.5, -0.5,
    -0.5, -0.5,  0.5,
    -0.5,  0.5,  0.5,
    -0.5,  0.5, -0.5,
  ];

  final normals = <double>[
    // Front
    0, 0, 1,   0, 0, 1,   0, 0, 1,   0, 0, 1,
    // Back
    0, 0, -1,  0, 0, -1,  0, 0, -1,  0, 0, -1,
    // Top
    0, 1, 0,   0, 1, 0,   0, 1, 0,   0, 1, 0,
    // Bottom
    0, -1, 0,  0, -1, 0,  0, -1, 0,  0, -1, 0,
    // Right
    1, 0, 0,   1, 0, 0,   1, 0, 0,   1, 0, 0,
    // Left
    -1, 0, 0,  -1, 0, 0,  -1, 0, 0,  -1, 0, 0,
  ];

  final indices = <int>[
    0, 1, 2,  0, 2, 3,
    4, 5, 6,  4, 6, 7,
    8, 9, 10, 8, 10, 11,
    12, 13, 14, 12, 14, 15,
    16, 17, 18, 16, 18, 19,
    20, 21, 22, 20, 22, 23,
  ];

  // Animation keyframe times: 0.0s, 0.5s, 1.0s
  final animTimes = <double>[0.0, 0.5, 1.0];
  
  // Idle animation translations: bob up and down
  final idleTranslations = <double>[
    0.0, 0.0, 0.0,
    0.0, 0.15, 0.0,
    0.0, 0.0, 0.0,
  ];

  // Walk animation rotations (quaternions X, Y, Z, W)
  final walkRotations = <double>[
    0.0, 0.0, 0.0, 1.0,
    0.0, 0.1, 0.0, 0.995,
    0.0, -0.1, 0.0, 0.995,
  ];

  // Dance animation: scale jump & squash
  final danceScales = <double>[
    1.0, 1.0, 1.0,
    1.15, 0.85, 1.15,
    1.0, 1.0, 1.0,
  ];

  // Buffer offsets
  // 1. Indices (uint16)
  final indicesByteOffset = bin.length;
  final indicesData = ByteData(indices.length * 2);
  for (int i = 0; i < indices.length; i++) {
    indicesData.setUint16(i * 2, indices[i], Endian.little);
  }
  bin.add(indicesData.buffer.asUint8List());

  // 2. Positions (float32)
  final posByteOffset = bin.length;
  final posData = ByteData(positions.length * 4);
  for (int i = 0; i < positions.length; i++) {
    posData.setFloat32(i * 4, positions[i], Endian.little);
  }
  bin.add(posData.buffer.asUint8List());

  // 3. Normals (float32)
  final normByteOffset = bin.length;
  final normData = ByteData(normals.length * 4);
  for (int i = 0; i < normals.length; i++) {
    normData.setFloat32(i * 4, normals[i], Endian.little);
  }
  bin.add(normData.buffer.asUint8List());

  // 4. Animation times (float32)
  final animTimeByteOffset = bin.length;
  final animTimeData = ByteData(animTimes.length * 4);
  for (int i = 0; i < animTimes.length; i++) {
    animTimeData.setFloat32(i * 4, animTimes[i], Endian.little);
  }
  bin.add(animTimeData.buffer.asUint8List());

  // 5. Idle translation values (float32)
  final idleByteOffset = bin.length;
  final idleData = ByteData(idleTranslations.length * 4);
  for (int i = 0; i < idleTranslations.length; i++) {
    idleData.setFloat32(i * 4, idleTranslations[i], Endian.little);
  }
  bin.add(idleData.buffer.asUint8List());

  // 6. Walk rotation values (float32 quaternions)
  final walkByteOffset = bin.length;
  final walkData = ByteData(walkRotations.length * 4);
  for (int i = 0; i < walkRotations.length; i++) {
    walkData.setFloat32(i * 4, walkRotations[i], Endian.little);
  }
  bin.add(walkData.buffer.asUint8List());

  // 7. Dance scale values (float32)
  final danceByteOffset = bin.length;
  final danceData = ByteData(danceScales.length * 4);
  for (int i = 0; i < danceScales.length; i++) {
    danceData.setFloat32(i * 4, danceScales[i], Endian.little);
  }
  bin.add(danceData.buffer.asUint8List());

  final binBytes = bin.toBytes();

  final gltfJson = {
    "asset": {"version": "2.0", "generator": "WalkingDoll GLB Asset Generator"},
    "scene": 0,
    "scenes": [
      {
        "nodes": [0]
      }
    ],
    "nodes": [
      {
        "name": "DollRootNode",
        "mesh": 0,
        "translation": [0.0, 0.0, 0.0],
        "rotation": [0.0, 0.0, 0.0, 1.0],
        "scale": [1.0, 1.0, 1.0]
      }
    ],
    "meshes": [
      {
        "name": "AstroDollMesh",
        "primitives": [
          {
            "attributes": {"POSITION": 1, "NORMAL": 2},
            "indices": 0,
            "material": 0
          }
        ]
      }
    ],
    "materials": [
      {
        "name": "PastelDollMaterial",
        "pbrMetallicRoughness": {
          "baseColorFactor": [1.0, 0.65, 0.82, 1.0], // Cute pink pastel
          "metallicFactor": 0.1,
          "roughnessFactor": 0.5
        }
      }
    ],
    "animations": [
      {
        "name": "idle",
        "channels": [
          {
            "sampler": 0,
            "target": {"node": 0, "path": "translation"}
          }
        ],
        "samplers": [
          {"input": 3, "interpolation": "LINEAR", "output": 4}
        ]
      },
      {
        "name": "walk",
        "channels": [
          {
            "sampler": 0,
            "target": {"node": 0, "path": "rotation"}
          }
        ],
        "samplers": [
          {"input": 3, "interpolation": "LINEAR", "output": 5}
        ]
      },
      {
        "name": "dance",
        "channels": [
          {
            "sampler": 0,
            "target": {"node": 0, "path": "scale"}
          }
        ],
        "samplers": [
          {"input": 3, "interpolation": "LINEAR", "output": 6}
        ]
      }
    ],
    "accessors": [
      {
        "bufferView": 0,
        "byteOffset": 0,
        "componentType": 5123, // UNSIGNED_SHORT
        "count": indices.length,
        "type": "SCALAR"
      },
      {
        "bufferView": 1,
        "byteOffset": 0,
        "componentType": 5126, // FLOAT
        "count": 24,
        "type": "VEC3",
        "max": [0.5, 0.5, 0.5],
        "min": [-0.5, -0.5, -0.5]
      },
      {
        "bufferView": 2,
        "byteOffset": 0,
        "componentType": 5126, // FLOAT
        "count": 24,
        "type": "VEC3",
        "max": [1.0, 1.0, 1.0],
        "min": [-1.0, -1.0, -1.0]
      },
      {
        "bufferView": 3,
        "byteOffset": 0,
        "componentType": 5126, // FLOAT
        "count": 3,
        "type": "SCALAR",
        "max": [1.0],
        "min": [0.0]
      },
      {
        "bufferView": 4,
        "byteOffset": 0,
        "componentType": 5126, // FLOAT
        "count": 3,
        "type": "VEC3"
      },
      {
        "bufferView": 5,
        "byteOffset": 0,
        "componentType": 5126, // FLOAT
        "count": 3,
        "type": "VEC4"
      },
      {
        "bufferView": 6,
        "byteOffset": 0,
        "componentType": 5126, // FLOAT
        "count": 3,
        "type": "VEC3"
      }
    ],
    "bufferViews": [
      {
        "buffer": 0,
        "byteOffset": indicesByteOffset,
        "byteLength": indices.length * 2,
        "target": 34963 // ELEMENT_ARRAY_BUFFER
      },
      {
        "buffer": 0,
        "byteOffset": posByteOffset,
        "byteLength": positions.length * 4,
        "target": 34962 // ARRAY_BUFFER
      },
      {
        "buffer": 0,
        "byteOffset": normByteOffset,
        "byteLength": normals.length * 4,
        "target": 34962
      },
      {
        "buffer": 0,
        "byteOffset": animTimeByteOffset,
        "byteLength": animTimes.length * 4
      },
      {
        "buffer": 0,
        "byteOffset": idleByteOffset,
        "byteLength": idleTranslations.length * 4
      },
      {
        "buffer": 0,
        "byteOffset": walkByteOffset,
        "byteLength": walkRotations.length * 4
      },
      {
        "buffer": 0,
        "byteOffset": danceByteOffset,
        "byteLength": danceScales.length * 4
      }
    ],
    "buffers": [
      {
        "byteLength": binBytes.length
      }
    ]
  };

  return buildGlb(gltfJson, binBytes);
}

/// Generates a valid faceted 3D Prism Star GLB without embedded animations
/// (used to test the required Fallback Idle Animation!)
Uint8List generatePrismStarGlb() {
  final bin = BytesBuilder();

  // Octahedron (8 triangular faces, 6 vertices)
  final positions = <double>[
     0.0,  0.8,  0.0, // Top apex (0)
     0.0, -0.8,  0.0, // Bottom apex (1)
     0.6,  0.0,  0.0, // Right (2)
     0.0,  0.0,  0.6, // Front (3)
    -0.6,  0.0,  0.0, // Left (4)
     0.0,  0.0, -0.6, // Back (5)
  ];

  final normals = <double>[
    0.0, 1.0, 0.0,
    0.0, -1.0, 0.0,
    1.0, 0.0, 0.0,
    0.0, 0.0, 1.0,
    -1.0, 0.0, 0.0,
    0.0, 0.0, -1.0,
  ];

  final indices = <int>[
    // Upper 4 faces
    0, 3, 2,
    0, 4, 3,
    0, 5, 4,
    0, 2, 5,
    // Lower 4 faces
    1, 2, 3,
    1, 3, 4,
    1, 4, 5,
    1, 5, 2,
  ];

  final indicesOffset = bin.length;
  final indicesData = ByteData(indices.length * 2);
  for (int i = 0; i < indices.length; i++) {
    indicesData.setUint16(i * 2, indices[i], Endian.little);
  }
  bin.add(indicesData.buffer.asUint8List());

  final posOffset = bin.length;
  final posData = ByteData(positions.length * 4);
  for (int i = 0; i < positions.length; i++) {
    posData.setFloat32(i * 4, positions[i], Endian.little);
  }
  bin.add(posData.buffer.asUint8List());

  final normOffset = bin.length;
  final normData = ByteData(normals.length * 4);
  for (int i = 0; i < normals.length; i++) {
    normData.setFloat32(i * 4, normals[i], Endian.little);
  }
  bin.add(normData.buffer.asUint8List());

  final binBytes = bin.toBytes();

  final gltfJson = {
    "asset": {"version": "2.0", "generator": "WalkingDoll GLB Asset Generator"},
    "scene": 0,
    "scenes": [
      {
        "nodes": [0]
      }
    ],
    "nodes": [
      {
        "name": "PrismStarRoot",
        "mesh": 0
      }
    ],
    "meshes": [
      {
        "name": "PrismStarMesh",
        "primitives": [
          {
            "attributes": {"POSITION": 1, "NORMAL": 2},
            "indices": 0,
            "material": 0
          }
        ]
      }
    ],
    "materials": [
      {
        "name": "CrystalCyanMaterial",
        "pbrMetallicRoughness": {
          "baseColorFactor": [0.3, 0.85, 0.95, 0.85], // Glowing cyan gem
          "metallicFactor": 0.3,
          "roughnessFactor": 0.2
        }
      }
    ],
    "accessors": [
      {
        "bufferView": 0,
        "byteOffset": 0,
        "componentType": 5123,
        "count": indices.length,
        "type": "SCALAR"
      },
      {
        "bufferView": 1,
        "byteOffset": 0,
        "componentType": 5126,
        "count": 6,
        "type": "VEC3",
        "max": [0.6, 0.8, 0.6],
        "min": [-0.6, -0.8, -0.6]
      },
      {
        "bufferView": 2,
        "byteOffset": 0,
        "componentType": 5126,
        "count": 6,
        "type": "VEC3",
        "max": [1.0, 1.0, 1.0],
        "min": [-1.0, -1.0, -1.0]
      }
    ],
    "bufferViews": [
      {
        "buffer": 0,
        "byteOffset": indicesOffset,
        "byteLength": indices.length * 2,
        "target": 34963
      },
      {
        "buffer": 0,
        "byteOffset": posOffset,
        "byteLength": positions.length * 4,
        "target": 34962
      },
      {
        "buffer": 0,
        "byteOffset": normOffset,
        "byteLength": normals.length * 4,
        "target": 34962
      }
    ],
    "buffers": [
      {
        "byteLength": binBytes.length
      }
    ]
  };

  return buildGlb(gltfJson, binBytes);
}
