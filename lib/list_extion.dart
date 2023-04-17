int checkSum(List<int> data) {
  var total = data.reduce((value, element) => value + element);

  return total & 0xff;
}
