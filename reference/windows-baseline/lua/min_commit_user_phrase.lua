-- Keep user entries selectable even while they are still provisional.
-- ScriptTranslator removes a same-text static candidate before Lua filters
-- run, so hiding a low-commit user entry here would make it unreachable and
-- unable to accumulate the commits needed for promotion.

-- Explicitly rejected phrases stay hidden even if their historic count is
-- already high.  Add only phrases the user has reviewed and rejected here.
local blocked_user_phrases = {
  ["它股"] = true,
  ["端的"] = true,
}

local function should_hide(candidate)
  return candidate.type == "user_phrase"
    and blocked_user_phrases[candidate.text] == true
end

-- A confirmed segment can split a multi-character Dayi code into a new
-- segment.  In that case the ordinary adaptive ranking only sees `a3`, even
-- when the immediately preceding confirmed character is `工`.  Preserve the
-- normal candidate objects and merely move `作` ahead for this one intended
-- continuation, so user-dictionary learning continues to work unchanged.
local function should_prioritize_work(context, candidate)
  if candidate.text ~= "作" then
    return false
  end

  -- Rime offsets are zero-based and end-exclusive; Lua string indexes are
  -- one-based and inclusive.
  if context.input:sub(candidate.start + 1, candidate._end) ~= "a3" then
    return false
  end

  local segmentation = context.composition:toSegmentation()
  if not segmentation then
    return false
  end

  -- Find the segment immediately before this candidate.  Requiring an exact
  -- confirmed `工` keeps this override out of unrelated `a3` input.
  for index = segmentation.size - 1, 0, -1 do
    local previous = segmentation:get_at(index)
    if previous and previous._end == candidate.start then
      if previous.status ~= "kConfirmed" then
        return false
      end
      local selected = previous:get_selected_candidate()
      return selected and selected.text == "工" or false
    end
  end

  return false
end

return function(input, env)
  local deferred = {}
  local promoted = false
  local context = env.engine.context

  for candidate in input:iter() do
    if not should_hide(candidate) then
      if not promoted and should_prioritize_work(context, candidate) then
        yield(candidate)
        promoted = true
      else
        table.insert(deferred, candidate)
      end
    end
  end

  for _, candidate in ipairs(deferred) do
    yield(candidate)
  end
end
