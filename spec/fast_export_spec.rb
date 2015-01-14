# -*- encoding: utf-8 -*-
require 'spec_helper'

describe "notes#cboxes" do
  let(:filename) { 'test.note' }
  specify "#create item inline" do
    before <<-EOF
    EOF
    vim.normal 'I[ ]'
    after <<-EOF
    [ ]
    EOF
  end
  specify "#create item below" do
    before <<-EOF
    [ ]
    EOF
    vim.normal 'o[ ]'
    after <<-EOF
    [ ]
    [ ]
    EOF
  end
  specify "#create item above" do
    before <<-EOF
    [ ]
    EOF
    vim.normal 'O[ ]'
    after <<-EOF
    [ ]
    [ ]
    EOF
  end
  specify "#toggle checkbox" do
    before <<-EOF
    [ ]
    EOF
    vim.command("call notes#toggle_checkbox(line('.'))")
    after <<-EOF
    [x]
    EOF
  end
end

