# -*- encoding: utf-8 -*-
require 'spec_helper'

describe "notes#edit" do
  it "returns a new Note if you open a new buffer" do
    vim.command('call notes#edit("test")')
    #vim.edit "test.note"
    vim.insert("This is a simple test note")
    vim.write
  end
end

describe "notes#list" do
  it "list all the existing notes" do
    vim.command('execute :Explore .')
  end
end

describe "notes#delete" do
  it "delete test.note" do
    vim.command('call notes#delete("test.note")')
  end
end

describe "notes#templates" do
  it "init template (sanity check)" do
    vim.command('call notes#templates()')
    vim.edit('test.note')
    vim.write
    # Read and print the generated note content
    f = IO.read('test.note')
    # Print the resulting content
    puts f
    vim.command('call notes#delete("test.note")')
  end
end
