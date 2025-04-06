; internal, this class is used to debug / catch runtime errors
/*!
  Class: RDA_Base
    Base class

    * Utils for chaining any class
*/
class RDA_Base {
  ;
  ; chaining utils
  ;
  /*!
    Method: sleep
      sleeps some miliseconds

    Parameters:
      ms - number - miliseconds

    Returns:
      this - for chaining
  */
  sleep(ms) {
    sleep % ms
    return this
  }
  /*!
    Method: sleep
      sleeps some random miliseconds

    Parameters:
      minMs - number - minimum, miliseconds
      maxMs - number - maximum, miliseconds

    Returns:
      this - for chaining
  */
  randomSleep(minMs, maxMs) {
    local

    Random, rnd , % minMs, % maxMs

    return this.sleep(rnd)
  }
}
