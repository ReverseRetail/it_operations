# frozen_string_literal: true
require 'spec_helper'

RSpec.describe ItOperations do
  it "has a version number" do
    expect(ItOperations::VERSION).not_to be nil
  end

  let(:operation_klass) { ItOperations::ItOperation }

  it '.entities_for_operation' do
    entity = operation_klass.create(entity_id: 1, entity_class: 'Test', operation: 'create entity')
    it_operation = operation_klass.create(entity_id: entity.id, entity_class: operation_klass.name, operation: 'test')

    expect(described_class.entities_for_operation(it_operation.operation)).to eq([entity])
  end

  describe '.run' do
    let(:it_operation) { operation_klass.new(entity_class: operation_klass.name, operation: 'test') }

    before do
      entity = operation_klass.create(entity_id: 1, entity_class: 'Test')
      it_operation.entity_id = entity.id
      it_operation.save
    end

    context 'when the operation succeeds' do
      let(:run_operation) do
        described_class.run(it_operation.operation, 'succeed!') { true }
      end

      it 'stores the result' do
        expect do
          run_operation
          it_operation.reload
        end.to change(it_operation, :result).to('succeed!')
      end

      it 'marks it as successful' do
        expect do
          run_operation
          it_operation.reload
        end.to change(it_operation, :successful).from(false).to(true)
      end
    end

    context 'when the operation fails' do
      let(:run_operation) do
        described_class.run(it_operation.operation) { raise 'Some Error' }
      end

      it 'stores the result' do
        expect do
          run_operation
          it_operation.reload
        end.to change(it_operation, :result).to('Some Error')
      end

      it 'marks it as failed' do
        expect do
          run_operation
          it_operation.reload
        end.to change {
          [it_operation.processed, it_operation.successful, it_operation.result]
        }.from([false, false, nil]).to([true, false, 'Some Error'])
      end
    end
  end
end
