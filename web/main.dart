import 'dart:html';
import 'dart:math';

final Random random = new Random();
final CanvasElement display = querySelector('#display');
final SpanElement generationSpan = querySelector('#generation');
final ButtonElement runButton = querySelector('#run');
final TextAreaElement textArea = querySelector('#input');
bool running = false;

main() async {
  runButton.onClick.listen((data) async {
    if (!running) {
      running = true;
      runButton.text = 'Stop';
      final input = textArea.value.split(new RegExp(r'\s+'));
      final population = int.parse(input[0]);
      final infected = int.parse(input[1]);
      final attributeMap = createAttributeMap(input);
      ImageData imageData = createImageData(population);
      var rawData = imageData.data;

      final List<int> populationIds =
      new List.generate(population, (index) => index);
      populationIds.shuffle();
      for (int i = 0; i < infected; i++) {
        rawData[populationIds[i] * 4] = 255;
      }
      display.context2D.putImageData(imageData, 0, 0);

      var generation = 0;
      var immune = 0;
      var attributes = attributeMap[0];
      generationSpan.text = '$generation';
      while (running) {
        await window.animationFrame;
        if (attributeMap.containsKey(generation)) {
          attributes = attributeMap[generation];
        }
        for (int i = 0; i < population; i++) {
          if (rawData[i * 4 + 1] == 255) continue;
          if (rawData[i * 4] == 255) {
            if (random.nextDouble() < attributes.healingRate) {
              rawData[i * 4] = 0;
              rawData[i * 4 + 1] = 255;
              immune++;
            }
            continue;
          }
          if (random.nextDouble() < attributes.patchRate) {
            rawData[i * 4 + 1] = 255;
            immune++;
          } else if (random.nextDouble() < attributes.infectionRate) {
            rawData[i * 4] = 255;
          }
        }
        display.context2D.putImageData(imageData, 0, 0);
        if (immune == population) {
          running = false;
          runButton.text = 'Run';
        }
        generation++;
        generationSpan.text = '$generation';
      }
    } else {
      running = false;
      runButton.text = 'Run';
    }
  });
}

ImageData createImageData(int population) {
  final canvasSize = sqrt(population).ceil();
  display
    ..width = canvasSize
    ..height = canvasSize;
  display.context2D
    ..imageSmoothingEnabled = false
    ..fillStyle = 'black'
    ..fillRect(0, 0, canvasSize, canvasSize);
  return display.context2D.getImageData(0, 0, canvasSize, canvasSize);
}

Map<int, Attributes> createAttributeMap(List<String> input) {
  Map<int, Attributes> attributeMap = {};
  attributeMap[0] = new Attributes(
      double.parse(input[2]), double.parse(input[3]), double.parse(input[4]));
  for (int i = 5; i < input.length; i += 4) {
    attributeMap[int.parse(input[i])] = new Attributes(
        double.parse(input[i + 1]),
        double.parse(input[i + 2]),
        double.parse(input[i + 3]));
  }
  return attributeMap;
}

class Attributes {
  double infectionRate;
  double healingRate;
  double patchRate;

  Attributes(this.infectionRate, this.healingRate, this.patchRate);
}
