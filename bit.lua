----------------------

local _VERSION, packageName, packageAuthor, packageRepository =
  '0.1.0', 'PureLuaBit32', 'Expo', {
    url = 'https://github.com/Exponential-Workload/plb/tree/master',
    type = 'git',
  }
local packageMetadata = {
  _TYPE = 'module',
  _NAME = packageName,
  _VERSION = _VERSION,
  _REPOSITORY = packageRepository,
  name = packageName,
  description = 'Pure Lua implementation of bit32 library',
  author = packageAuthor,
  license = 'MIT',
  homepage = 'https://bit.astolfo.gay',
  repository = packageRepository,
}

----------------------

local selfTest = false
local native = selfTest and (bit or bit32)

----------------------

local pow, modulo, floor, ceil, round, factorial, exp, log, abs, clamp, huge, pi, max, min
local bor, band, bnot, bxor, lshift, rshift

----------------------

pow = function(base, exponent)
  if exponent == 1 then
    return base
  elseif exponent == 0 then
    return 1
  else
    return base * pow(base, exponent - 1)
  end
end

modulo = function(a, b)
  -- no im not rewriting this
  return a % b
end

floor = function(a)
  return a - modulo(a, 1)
end

ceil = function(a)
  local mod = modulo(a, 1)
  if mod == 0 then
    return a
  else
    return a - mod + 1
  end
end

round = function(a)
  local mod = modulo(a, 1)
  if mod < 0.5 then
    return a - mod
  else
    return a - mod + 1
  end
end

factorial = function(n)
  if n == 0 then
    return 1
  else
    return n * factorial(n - 1)
  end
end

exp = function(x)
  local res = 1
  for i = 1, 100 do
    res = res + pow(x, i) / factorial(i)
  end
  return res
end

log = function(arg, base)
  if not base then
    local sum = 0
    local term = (arg - 1) / arg
    local power = term
    local i = 1

    while i < 100 do
      sum = sum + power / i
      power = power * term
      i = i + 1
    end

    return sum
  else
    local res = 0
    while arg > 1 do
      arg = arg / base
      res = res + 1
    end
    return res
  end
end

abs = function(n)
  return n < 0 and -n or n
end

clamp = function(n, min, max)
  return n < min and min or n > max and max or n
end

huge = Infinity or (math and math.huge) or pow(1, 1000)

pi = 3.141592653589793238462643383279502884197169399375105820974944592307816406286

max = function(...)
  local args = { ... }
  local _max = -huge
  for i = 1, #args do
    if args[i] > _max then
      _max = args[i]
    end
  end
  return _max
end

min = function(...)
  local args = { ... }
  local _min = huge
  for i = 1, #args do
    if args[i] < _min then
      _min = args[i]
    end
  end
  return _min
end

----------------------

local meth = {
  pow = pow,
  modulo = modulo,
  floor = floor,
  ceil = ceil,
  round = round,
  factorial = factorial,
  exp = exp,
  log = log,
  abs = abs,
  clamp = clamp,
  huge = huge,
  maxinteger = 9223372036854775807,
  mininteger = -9223372036854775808,
  pi = pi,
  max = max,
  min = min,
}

----------------------

bor = function(x, y)
  local result = 0
  local p = 1
  while x > 0 or y > 0 do
    if x % 2 + y % 2 > 0 then
      result = result + p
    end
    x = floor(x / 2)
    y = floor(y / 2)
    p = p * 2
  end
  return result
end
band = function(a, b)
  local result = 0
  local bitval = 1
  while a > 0 and b > 0 do
    if a % 2 == 1 and b % 2 == 1 then
      result = result + bitval
    end
    bitval = bitval * 2
    a = floor(a / 2)
    b = floor(b / 2)
  end
  return result
end
bnot = function(n)
  local result = 0
  local bitval = 1
  for _ = 0, 31 do
    if n % 2 == 0 then
      result = result + bitval
    end
    n = floor(n / 2)
    bitval = bitval * 2
  end
  return result
end
bxor = function--[[(a, b)
  local res = bor(band(bnot(a), b), band(a, bnot(b)))
  return res
end]](a, b)
  local p, res = 1, 0
  while a > 0 and b > 0 do
    local ra, rb = a % 2, b % 2
    if ra ~= rb then
      res = res + p
    end
    p, a, b = p * 2, floor(a / 2), floor(b / 2)
  end
  res = res + a * p + b * p
  return res
end
lshift = function(a, b)
  return (a * pow(2, b)) % pow(2, 32)
end
rshift = function(x, by)
  return floor(x / pow(2, by))
end

----------------------

local bitPoly = {
  pow = pow,
  bor = bor,
  band = band,
  bnot = bnot,
  bxor = bxor,
  lshift = lshift,
  rshift = rshift,
}

----------------------

local randomLib = (function()
  local primes = { 7247392010727657073, 8400710862129544859, 7550132569134999817, 7043851128195078653 }
  local jsf_new, jsfseed1, jsfseed2, jsfseed3, jsfseed4
  local getSeeds = function(primes)
    if not (primes[1] and primes[2] and primes[3] and primes[4]) then
      error 'Must pass table of 4 primes to the primeless random function'
    end
    local clock = os.clock
    local ourClock1 = clock()
    local ourClock1Split = (tonumber(string.split(tostring(ourClock1), '.')[2] or '1'))
    local ourTime = os.time() + ourClock1 % 1
    -- use some cpu time
    do
      local _rn = jsf_new(1, 1, 1, 1)
      for _ = 0, 10, 1 do
        _rn(_, _ * 10)
      end
    end
    local ourClock2 = clock()
    local ourClock2Split = (tonumber(string.split(tostring(ourClock2), '.')[2] or '1') or ourClock2 * 10)
    local ourClock3 = clock() - (ourClock2 - ourClock1)
    local ourClock3Split = (tonumber(string.split(tostring(ourClock3), '.')[2] or '1'))
    local seedA = bxor(ourClock1, ourTime + ourClock3Split or ourClock2 * 10)
    local seedB = bxor(ourClock2Split, ourClock3)
    local seedC = bxor(bxor(bxor(ourClock1 * #tostring(ourClock1 % 1), primes[1]), ourClock3Split), primes[2])
    local seedD = bxor(bxor(bxor(ourClock2 * #tostring(ourClock3 % 1), primes[3]), ourClock1Split), primes[4])

    return seedA, seedB, seedC, seedD ---- FOR MIN,MAX CALLS: FLOOR THE RESULT OF THIS FUNCTION IF U WANT IT TO BE AN INT
  end
  local jsfStartingSeed1, jsfStartingSeed2, jsfStartingSeed3, jsfStartingSeed4
  jsf_new, jsfseed1, jsfseed2, jsfseed3, jsfseed4 =
    function(a, b, c, d, p)
      if a == false then
        a = nil
      end
      if a == true then
        a, b, c, d = getSeeds(p or primes)
      elseif a == nil then
        a = jsfStartingSeed1
        if b == nil then
          b = jsfStartingSeed2
        end
        if c == nil then
          c = jsfStartingSeed3
        end
        if d == nil then
          d = jsfStartingSeed4
        end
      elseif b == nil then
        b = a
      elseif c == nil then
        c = a
      elseif d == nil then
        d = a
      end
      return function(min, max)
        if min == nil then
          min = 0
        end
        if max == nil then
          max = 1
        end
        a = bit32.bor(a, 0)
        b = bit32.bor(b, 0)
        c = bit32.bor(c, 0)
        d = bit32.bor(d, 0)
        local t = bit32.bor(a - (bit32.bor(bit32.lshift(b, 27), bit32.rshift(b, 5))), 0)
        a = bit32.bxor(b, (bit32.bor(bit32.lshift(c, 17), bit32.rshift(c, 15))))
        b = bit32.bor(c + d, 0)
        c = bit32.bor(d + t, 0)
        d = bit32.bor(a + t, 0)
        if min > max then
          local storage = min
          min = max
          max = storage
        end
        return ((bit32.rshift(d, 0)) / 4294967296) * (max - min) + min
      end
    end, 1, 2, 3, 4
  pcall(function()
    jsfseed1, jsfseed2, jsfseed3, jsfseed4 = getSeeds(primes)
  end)
  jsfStartingSeed1, jsfStartingSeed2, jsfStartingSeed3, jsfStartingSeed4 = jsfseed1, jsfseed2, jsfseed3, jsfseed4

  local jsf = jsf_new()

  meth.random = function(mini, maxi)
    return floor(jsf(mini, maxi))
  end
  meth.randomseed = function(seed)
    jsf = jsf_new(seed)
  end
  meth.jsf = {
    use = function(minimum, maximum)
      return jsf(minimum, maximum)
    end,
    new = jsf_new,
  }
  local Random = {}
  Random.new = function(seed1, seed2, seed3, seed4, primeNumbers)
    local jsf = jsf_new(seed1, seed2, seed3, seed4, primeNumbers and #primeNumbers > 3 and primeNumbers or primes)
  end
  return Random
end)()

----------------------

if selfTest then
  local powLoadstr = (load or loadstring) [[return function(a, b)
  return a ^ b
end]]() or function() end
  local test = function(min, max, step)
    for a = min, max, step do
      for b = min, max, step do
        local test = function(n, f)
          local x, y = ((native)[n] or f)(a, b), (bitPoly[n])(a, b)
          if x ~= y then
            error(
              'Function missmatch: '
                .. n
                .. '('
                .. tostring(a)
                .. ','
                .. tostring(b)
                .. ') -> bit32('
                .. tostring(x)
                .. ') ~= polyfill('
                .. tostring(y)
                .. ')'
            )
          end
        end
        print('test', a, b)
        test 'bor'
        test 'band'
        test 'bnot'
        test 'bxor'
        -- prevent shifting too far causing errors with -nan where l/rshift return 0
        if b < 64 or bit32.lshift(a, b) > 0 then
          test 'lshift'
        end
        test 'rshift'
        -- my pow has more accuracy than pure lua pow
        local powVal = powLoadstr(a, b)
        if powVal < 1e+10 then
          test('pow', function()
            return powVal
          end)
        end
      end
    end
  end
  test(0, 255, 1)
  test(1, 512, 2)
  test(1, 1024, 8)
  test(1, 16384, 64)
  test(1, 32768, 127)
end

----------------------

local package = {}
for k, v in pairs(bitPoly) do
  package[k] = v
end
for k, v in pairs(packageMetadata) do
  package[k] = v
end
package.bit = bitPoly
package.bit32 = bitPoly
package.math = meth
package.Random = randomLib
return package

----------------------
